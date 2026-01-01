# Project IV Pemodelan Data Lanjut
> Tugas Basis Data Temporal

## Table of Contents
- [Project IV Pemodelan Data Lanjut](#project-iv-pemodelan-data-lanjut)
  - [Table of Contents](#table-of-contents)
  - [General Information](#general-information)
  - [Technologies Used](#technologies-used)
  - [Features](#features)
  - [Screenshots](#screenshots)
  - [Setup](#setup)
    - [1. Install Python dependencies](#1-install-python-dependencies)
    - [2. Set up environment variables](#2-set-up-environment-variables)
    - [3. Make sure your PostgreSQL database is set up](#3-make-sure-your-postgresql-database-is-set-up)
    - [4. Seed Database](#4-seed-database)
  - [Usage](#usage)
  - [Project Status](#project-status)
  - [Room for Improvement](#room-for-improvement)
  - [Acknowledgements](#acknowledgements)
  - [Contact](#contact)


## General Information
- Provide general information about your project here.
- What problem does it (intend to) solve?
- What is the purpose of your project?
- Why did you undertake it?


## Technologies Used
- postgres


## Features
List the ready features here:
- Awesome feature 1
- Awesome feature 2
- Awesome feature 3


## Screenshots
![Example screenshot](./img/screenshot.png)
<!-- If you have screenshots you'd like to share, include them here. -->


## Setup
What are the project requirements/dependencies? Where are they listed? A requirements.txt or a Pipfile.lock file perhaps? Where is it located?

Proceed to describe how to install / setup one's local environment / get started with the project.
### 1. Install Python dependencies
```bash
pip install Faker==22.0.0 psycopg2-binary==2.9.9 python-dotenv==1.0.0
```

### 2. Set up environment variables
Copy the example environment file and edit it with your database credentials:

```ini
DB_NAME=project_iv_pdl
DB_USER=postgres
DB_PASSWORD=your_actual_password
DB_HOST=localhost
DB_PORT=5432
```

### 3. Make sure your PostgreSQL database is set up

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE project_iv_pdl;
```

### 4. Seed Database
```bash
python seeder.py
```


## Usage
How does one go about using it?
Provide various use cases and code examples here.

`write-your-code-here`


## Project Status
Project is: _in progress_ 


## Room for Improvement
Include areas you believe need improvement / could be improved. Also add TODOs for future development.

Room for improvement:
- Improvement to be done 1
- Improvement to be done 2

To do:
- Feature to be added 1
- Feature to be added 2


## Acknowledgements
Give credit here.
- This project was inspired by...
- This project was based on [this tutorial](https://www.example.com).
- Many thanks to...


## Contact
Created by [@flynerdpl](https://www.flynerd.pl/) - feel free to contact me!


<!-- Optional -->
<!-- ## License -->
<!-- This project is open source and available under the [... License](). -->

<!-- You don't have to include all sections - just the one's relevant to your project -->