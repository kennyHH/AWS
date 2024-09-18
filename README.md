
<h1 align="center">🐳 LAMP Stack Docker Project 🐳</h1>

<div align="center">
  <img src="https://miro.medium.com/v2/resize:fit:640/format:webp/0*8gspH6Y2Q141WeLT.jpg" alt="LAMP Docker Logo">
</div>



This project sets up a LAMP (Linux, Apache, MySQL, PHP) stack using Docker, with additional features for user management and web hosting. It's designed to create a development environment for multiple user groups with different access levels.

## 🌟 Features

- 🐧 Linux + 🚀 Apache + 🐬 MySQL + 🐘 PHP containerized with Docker
- 👥 Multiple user groups with different access levels:
  - `webdev`: Web development users with their own web directories
  - `compsc`: Computer Science users 
  - `admin` : Administrators
- 💾 Persistent user data and MySQL databases
- 🔐 SSH access for Computer Science and Other users
- ⚓ FTP access for Web development users
- 🛠 PhpMyAdmin for database management for all


## 🏗 Architecture

### Permissions

|  Class Name | Group name  | Naming Convention | MySQL | phpMyAdmin | FTP access | SSH access | Web publish
| ---------- | ----------- | ----------------- | :---: | :--------: | :--------: | :--------: | :--------: |
| Web Development    | webdev | hnXwebsa + studentname       |   X   |     X      |     X      |            |        X    |
| Computer Science      | compsc | hnXcss + studentname       |   X   |     X      |        X    |     X      |            |

## 📁 Project Structure

- `/config/`: Configuration files
- `/persistent_folders/`: Persistent data
  - `/apache/`: Apache configuration
  - `/home/`: User home directories
  - `/mysql_data/`: MySQL data
  - `/setup_flag/`: Setup status flags
- `/scripts/`: Setup and maintenance scripts
- `/users_csv/`: User data and generation scripts

## 💾 Persistence

User data including home folders and MySQL databases persist across container restarts.

# Getting started
### 🛠 Prerequisites

- Docker 🐳
- Docker Compose 🐙

## 🚀 Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/kennyHH/AWS.git
   cd AWS
   ```

2. Generate user CSV files using the `generate_users.sh` script in the `./users_csv` directory.

3. Modify a `.env` file in the project root and change MySQL password:
   ```
   MYSQL_ROOT_PASSWORD=your_secure_password_here
   ```
   
4. Change the `PMA_ABSOLUTE_URI` in `docker-compose.yaml` file.

5. Build and start the containers:
   ```bash
   docker-compose up -d --build
   ```

>[!TIP] 
> To recreate the environment from scratch, use the `cleanup.sh` script in the `./persistent_folders` directory.

![demo](gifs/cleanup.gif)

## 🖥 Usage

- Apache web server is accessible at `http://<ip>`
- PhpMyAdmin is accessible at `http://<ip>/phpmyadmin`
- Student websites are accessible at `http://<ip>/<student_login_here>` i.e `http://192.168.1.241/hncwebsajcole` etc.
- SSH/SFTP into the Apache container:
  ```bash
  ssh -p 22 <username>@<ip>
  ```
- To connect to MySQL after logging using SSH:
  ```bash
  mysql -h mysql -P 3306 -u<username> -p
  ```

## 👤 User Generation and Management 

This project uses a custom script to generate user accounts for different groups. The `generate_users.sh` script in the `./users_csv` directory automates the process of creating user credentials for various course groups.

The Administrators details can be changed in `./users_csv/csv/admin_users.csv`.

![demo](gifs/user_gen.gif)

### How it works

1. The script reads from input files containing student names for different courses.
2. It generates usernames based on the course code and student names.
3. Random passwords are created for each user.
4. The script outputs CSV files with usernames, passwords for each course group and saves it in folder `csv`.

### Usage

1. Navigate to the `./users_csv` directory: `cd users_csv`
2. Fill up the txt files with students details in a format : `First Name` `Surname`
3. Run the script: `./generate_users.sh`
4. Follow the prompts to select the desired group for user generation.
5. The script will create CSV files in the `./users_csv/csv` directory, named after the selected group (e.g., `hncwebsa.csv`, `hndcsmr.csv`).

>[!TIP] 
>Leave CSV file empty in `./users_csv/csv` if you don't want to generate users for the specific group.

### Available Groups

- `HNCWEBSA`: HNC Web Development (Sighthill)
- `HNDWEBSA`: HND Web Development (Sighthill)
- `HNCWEBMR`: HNC Web Development (Milton Road)
- `HNDWEBMR`: HND Web Development (Milton Road)
- `HNCCSSA`: HNC Computer Science (Sighthill)
- `HNDCSSA`: HND Computer Science (Sighthill)
- `HNCCSMR`: HNC Computer Science (Milton Road)
- `HNDCSMR`: HND Computer Science (Milton Road)

### Output Format

The generated CSV files contain three columns:
- `USERNAME`: The generated username
- `PASSWORD`: A randomly generated password
- `FULLNAME`: The student's full name

Example:

```bash
USERNAME,PASSWORD,FULLNAME
HNCWEBSAJSMITH,Xa5tP9qR,John Smith
```

### Note

- The names of TXT and CSV files are hardcoded and can't be changed.
- Ensure that the input text files (`hncwebsa.txt`, `hndcsmr.txt`, etc.) are up-to-date with the correct student names before running the script.
- The generated CSV files are used by other scripts in the project to set up user accounts,databases and permissions.


## 🔒 Security Notes

- 🔑 Change default passwords in CSV files for production use
- 🛡️ Review and adjust file permissions as needed
- 🔐 Consider using Docker secrets for sensitive information in production


## 🔧 Bugs

#### Apache errors

- Apache configuration overlap warnings

## 🖥 Roadmap 


## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

<div align="center">
  Made with ❤️ by kennyH
</div>

