# 🐳 LAMP Stack Docker Project

<div align="center">
  <img src="https://via.placeholder.com/150?text=LAMP+Docker" alt="LAMP Docker Logo">
</div>

This project sets up a LAMP (Linux, Apache, MySQL, PHP) stack using Docker, with additional features for user management and web hosting. It's designed to create a development environment for multiple user groups with different access levels.

## 🌟 Features

- 🐧 Linux + 🚀 Apache + 🐬 MySQL + 🐘 PHP containerized with Docker
- 👥 Multiple user groups with different access levels:
  - `hncwebsa`: Web development users with their own web directories
  - `hnccssa`: Users with restricted access
  - `hncothers`: Other users with restricted access
- 💾 Persistent user data and MySQL databases
- 🛠 PhpMyAdmin for database management
- 🔐 SSH access for users

## 🏗 Architecture

<div align="center">
  <img src="https://via.placeholder.com/600x400?text=Project+Architecture+Diagram" alt="Project Architecture">
</div>

## 🛠 Prerequisites

- Docker 🐳
- Docker Compose 🐙

## 🚀 Setup

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Create necessary directories:
   ```bash
   mkdir -p persistent_home/hncwebsa persistent_home/otherusers
   ```

3. Copy your `hnccssa.csv`, `hncwebsa.csv`, and `hncothers.csv` files to the project root.

4. Create a `.env` file in the project root and add:
   ```
   MYSQL_ROOT_PASSWORD=your_secure_password_here
   ```

5. Build and start the containers:
   ```bash
   docker-compose up -d --build
   ```

## 🖥 Usage

- Apache web server is accessible at `http://localhost`
- PhpMyAdmin is accessible at `http://localhost:8080`
- SSH into the Apache container:
  ```bash
  ssh -p 2222 username@localhost
  ```

## 📁 Directory Structure

```mermaid
graph TD
    A[/home] --> B[/hncwebsa]
    A --> C[/otherusers]
    B --> D[/hncwebsa1]
    B --> E[/hncwebsa2]
    B --> F[...]
    C --> G[/hnccssa1]
    C --> H[/hnccssa2]
    C --> I[/hncother1]
    C --> J[...]
    D --> K[/website]
    E --> L[/website]
```

## 👤 User Management

Users are created based on the CSV files:
- `hncwebsa.csv`: Web development users
- `hnccssa.csv`: Restricted access users
- `hncothers.csv`: Other restricted access users

Format for CSV files:
```csv
username,password
```

## 💾 Persistence

User data and MySQL databases persist across container restarts.

<div align="center">
  <img src="https://via.placeholder.com/400x200?text=Data+Persistence+Diagram" alt="Data Persistence">
</div>

## 🔒 Security Notes

- 🔑 Change default passwords in CSV files for production use
- 🛡️ Review and adjust file permissions as needed
- 🔐 Consider using Docker secrets for sensitive information in production

## 🔧 Troubleshooting

If users are not persisting after container restarts, ensure that the `persistent_home` directory is properly mounted and has the correct permissions.

<div align="center">
  <img src="https://via.placeholder.com/400x200?text=Troubleshooting+Flowchart" alt="Troubleshooting Flowchart">
</div>

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

<div align="center">
  Made with ❤️ by [Your Name/Organization]
</div>
