#!/bin/bash
# ==============================================================================
# SCRIPT INSTALLASI OTOMATIS e-Rapor SMP Kurikulum Merdeka (Linux Server Edition)
# Target OS: Ubuntu 20.04 / 22.04 / 24.04 LTS, Debian 11 / 12
# Port Web : 8534
# Database : PostgreSQL (dbraporkemdikbud25)
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo "=============================================================================="
echo "   INSTALASI OTOMATIS e-Rapor SMP Kurikulum Merdeka (Linux Server Edition)"
echo "   Sistem e-Rapor Kurikulum Merdeka Kemendikdasmen - Versi Linux Server"
echo "=============================================================================="
echo ""

# Validasi akses root
if [ "$EUID" -ne 0 ]; then
    err "Harap jalankan script ini dengan akses root (sudo bash install_linux.sh)"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/var/www/eraporsmp"
DB_NAME="dbraporkemdikbud25"
DB_USER="postgres"
DB_PASS="secrets_deveraporsd2025*#rsp"
WEB_PORT="8534"

# Jika folder saat ini bukan TARGET_DIR dan belum dipindahkan, salin ke TARGET_DIR
if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
    info "Menyiapkan direktori aplikasi di $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    cp -rf "$SCRIPT_DIR"/* "$TARGET_DIR"/
    cp -rf "$SCRIPT_DIR"/.[!.]* "$TARGET_DIR"/ 2>/dev/null || true
    cd "$TARGET_DIR"
fi

# --- STEP 1: UPDATE & DEPENDENSI SISTEM ---
info "[1/7] Memperbarui repositori dan menginstal paket sistem..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl wget unzip software-properties-common gnupg2 lsb-release ca-certificates nginx postgresql postgresql-contrib postgresql-client

# --- STEP 2: INSTALL PHP 8.2 & EKSTENSI ---
info "[2/7] Memeriksa & menginstal PHP 8.2 beserta modul yang dibutuhkan..."
if ! command -v php8.2 >/dev/null 2>&1; then
    if [ -f /etc/lsb-release ] || grep -qi "ubuntu" /etc/os-release; then
        add-apt-repository ppa:ondrej/php -y
    elif [ -f /etc/debian_version ]; then
        curl -sSL https://packages.sury.org/php/README.txt | bash - 2>/dev/null || true
    fi
    apt-get update -y
fi

apt-get install -y php8.2 php8.2-fpm php8.2-pgsql php8.2-curl php8.2-gd \
    php8.2-mbstring php8.2-xml php8.2-zip php8.2-intl php8.2-bcmath

log "PHP 8.2 terinstal: $(php8.2 -v | head -1)"

# --- STEP 3: INSTALL IONCUBE LOADER 8.2 ---
info "[3/7] Memasang ionCube Loader untuk PHP 8.2 Linux x86_64..."
EXT_DIR=$(php8.2 -r "echo ini_get('extension_dir');")

if ! php8.2 -v | grep -qi "ioncube"; then
    mkdir -p /tmp/ioncube_dl
    cd /tmp/ioncube_dl
    if [ ! -f ioncube_loaders_lin_x86-64.tar.gz ]; then
        wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz || \
        curl -sSL -O https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
    fi
    tar -zxf ioncube_loaders_lin_x86-64.tar.gz
    cp -f ioncube/ioncube_loader_lin_8.2.so "$EXT_DIR/"
    cd "$TARGET_DIR"
    rm -rf /tmp/ioncube_dl

    for INI_DIR in /etc/php/8.2/fpm/conf.d /etc/php/8.2/cli/conf.d; do
        if [ -d "$INI_DIR" ]; then
            echo "zend_extension=$EXT_DIR/ioncube_loader_lin_8.2.so" > "$INI_DIR/00-ioncube.ini"
        fi
    done
fi

systemctl restart php8.2-fpm
if php8.2 -v | grep -qi "ioncube"; then
    log "ionCube Loader aktif!"
else
    warn "Perhatian: ionCube Loader belum terdeteksi di CLI. Memeriksa modul FPM..."
fi

# --- STEP 4: SETUP & RESTORE DATABASE POSTGRESQL ---
info "[4/7] Mengonfigurasi PostgreSQL dan merestore database $DB_NAME..."
systemctl enable postgresql
systemctl start postgresql

# Atur password user postgres
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$DB_PASS';" 2>/dev/null || true

# Putuskan koneksi yang ada dan buat database baru
sudo -u postgres psql << PSQL_EOF
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid != pg_backend_pid();
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME WITH ENCODING='SQL_ASCII' OWNER $DB_USER;
PSQL_EOF

# Restore template database
DUMP_FILE="$TARGET_DIR/database/database_template.sql"
if [ -f "$DUMP_FILE" ]; then
    sudo -u postgres psql -d "$DB_NAME" -f "$DUMP_FILE" >/dev/null 2>&1 || \
    sudo -u postgres psql -d "$DB_NAME" -f "$DUMP_FILE"
    log "Database $DB_NAME berhasil di-restore dari template!"
else
    warn "File $DUMP_FILE tidak ditemukan, lewati restore."
fi

# --- STEP 5: KONFIGURASI APLIKASI (.encapp & .env) ---
info "[5/7] Mengonfigurasi file lingkungan aplikasi..."
if [ -f "$TARGET_DIR/.encapp" ]; then
    sed -i 's/DB_PORT=[0-9]*/DB_PORT=5432/' "$TARGET_DIR/.encapp"
    sed -i "s/WebPort=[0-9]*/WebPort=$WEB_PORT/" "$TARGET_DIR/.encapp"
fi

if [ -f "$TARGET_DIR/.env" ]; then
    sed -i "s/# database.default.hostname = .*/database.default.hostname = localhost/" "$TARGET_DIR/.env"
    sed -i "s/# database.default.database = .*/database.default.database = $DB_NAME/" "$TARGET_DIR/.env"
    sed -i "s/# database.default.username = .*/database.default.username = postgres/" "$TARGET_DIR/.env"
    sed -i "s/# database.default.password = .*/database.default.password = $DB_PASS/" "$TARGET_DIR/.env"
    sed -i "s/# database.default.DBDriver = .*/database.default.DBDriver = Postgre/" "$TARGET_DIR/.env"
    sed -i "s/# database.default.port = .*/database.default.port = 5432/" "$TARGET_DIR/.env"
fi

# Pastikan direktori writable dan temporary folders siap
mkdir -p "$TARGET_DIR/writable/cache" "$TARGET_DIR/writable/logs" "$TARGET_DIR/writable/session" "$TARGET_DIR/writable/uploads"
mkdir -p "$TARGET_DIR/public/tempup" "$TARGET_DIR/public/restore" "$TARGET_DIR/public/bcfile"

chown -R www-data:www-data "$TARGET_DIR"
find "$TARGET_DIR" -type d -exec chmod 755 {} \;
find "$TARGET_DIR" -type f -exec chmod 644 {} \;
chmod +x "$TARGET_DIR/install_linux.sh" 2>/dev/null || true
chmod +x "$TARGET_DIR/spark" 2>/dev/null || true
chmod -R 777 "$TARGET_DIR/writable"
chmod -R 777 "$TARGET_DIR/public/tempup" "$TARGET_DIR/public/restore" "$TARGET_DIR/public/bcfile"
log "Hak akses direktori berhasil diatur."

# --- STEP 6: KONFIGURASI NGINX ---
info "[6/7] Menyiapkan Virtual Host Nginx pada Port $WEB_PORT..."
NGINX_CONF="/etc/nginx/sites-available/eraporsmp"
cat << NGINX_EOF > "$NGINX_CONF"
server {
    listen $WEB_PORT default_server;
    listen [::]:$WEB_PORT default_server;

    server_name _;
    root $TARGET_DIR/public;

    index index.php index.html index.htm;
    charset utf-8;

    client_max_body_size 500M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 600;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires max;
        log_not_found off;
    }
}
NGINX_EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/eraporsmp
nginx -t && systemctl reload nginx
log "Konfigurasi Nginx port $WEB_PORT aktif!"

# --- STEP 7: BUKA FIREWALL (UFW / FIREWALLD) ---
info "[7/7] Membuka port $WEB_PORT pada firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw allow $WEB_PORT/tcp >/dev/null 2>&1 || true
fi
if command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port=$WEB_PORT/tcp >/dev/null 2>&1 || true
    firewall-cmd --reload >/dev/null 2>&1 || true
fi

# Dapatkan IP Server
SERVER_IP=$(curl -s -m 3 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "=============================================================================="
echo -e "${GREEN}  INSTALASI e-Rapor SMP Kurikulum Merdeka (Linux Server Edition) SELESAI DENGAN SUKSES!${NC}"
echo "=============================================================================="
echo ""
echo "  URL Akses Lokal (LAN)  : http://$LOCAL_IP:$WEB_PORT"
if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "$LOCAL_IP" ]; then
    echo "  URL Akses Publik/Inet  : http://$PUBLIC_IP:$WEB_PORT"
fi
echo "  Web Root      : $TARGET_DIR/public"
echo "  Database      : $DB_NAME (PostgreSQL)"
echo "  Port DB       : 5432"
echo "  User DB       : postgres"
echo "  Password DB   : $DB_PASS"
echo ""
echo "  Status Layanan:"
echo "  - Nginx       : $(systemctl is-active nginx 2>/dev/null || echo unknown)"
echo "  - PHP 8.2 FPM : $(systemctl is-active php8.2-fpm 2>/dev/null || echo unknown)"
echo "  - PostgreSQL  : $(systemctl is-active postgresql 2>/dev/null || echo unknown)"
echo ""
echo "  Penghargaan & Terima Kasih Khusus kepada:"
echo "  Bapak I Nyoman Pasek, S.Pd., M.Pd. (Pengembang e-Rapor Kemendikdasmen)"
echo ""
echo "  Aplikasi sekarang siap digunakan dan disinkronkan dengan Dapodik!"
echo "=============================================================================="
