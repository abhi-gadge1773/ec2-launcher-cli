# 🚀 EC2 Launcher & ☠️ Terminator CLI

A powerful, interactive Bash-based CLI toolkit to **launch** and **terminate** EC2 instances on AWS right from your terminal. Designed to simplify AWS EC2 management for developers and DevOps engineers.

---

## 📦 Features

### 🚀 EC2 Launcher
- 🔧 Launch EC2 instances interactively
- 📍 Automatically detect default VPC & subnet
- 🔐 Create or use existing security groups
- 🖥️ Add user-defined instance name tags
- 🌐 Automatically whitelist your public IP in security group

### ☠️ EC2 Terminator
- ✅ List all running EC2 instances
- 🔍 Select instance to terminate interactively
- 🗑️ Terminate selected EC2 instance safely

---

## 📁 Project Structure

```
ec2-launcher-cli/
├── ec2-launcher.sh      # Launch new EC2 instances interactively
├── ec2-terminator.sh    # List and terminate EC2 instances interactively
└── README.md            # Project documentation
```

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/abhi-gadge1773/ec2-launcher-cli.git
cd ec2-launcher-cli
```

### 2. Make the Scripts Executable

```bash
chmod +x ec2-launcher.sh ec2-terminator.sh
```

---

## ⚙️ Prerequisites

- AWS CLI installed & configured (`aws configure`)
- IAM user with the following permissions:
  - `ec2:DescribeInstances`
  - `ec2:RunInstances`
  - `ec2:TerminateInstances`
  - `ec2:CreateSecurityGroup`
  - `ec2:AuthorizeSecurityGroupIngress`

- Bash Shell (Linux/macOS/Git Bash for Windows)

---

## ▶️ Usage

### Launch EC2 Instance

```bash
./ec2-launcher.sh
```

#### Sample Flow:
```
Enter your preferred region: us-east-1
Enter instance type (default: t2.micro):
Enter key pair name:
Enter instance name tag:
...

🌐 Your public IP: 203.0.113.42
✔️ EC2 instance launched successfully!
```

---

### Terminate EC2 Instance

```bash
./ec2-terminator.sh
```

#### Sample Flow:
```
Fetching running EC2 instances...

[1] i-0123abcd | Name: MyWebApp | State: running
[2] i-0456efgh | Name: DevServer | State: running

Choose an instance to terminate:
> 2

☠️ Terminating i-0456efgh...
✔️ Instance terminated successfully.
```

---

## 🔐 Safety Notes

- The terminator script **permanently deletes** EC2 instances. Always double-check instance IDs before confirming.
- Ensure you are using correct AWS region and key pair names while launching.

---

## 👨‍💻 Author

**Abhijeet Gadge**

- 💻 GitHub: [abhi-gadge1773](https://github.com/abhi-gadge1773)
- 💼 LinkedIn: [Abhijeet Gadge](https://www.linkedin.com/in/abhijeetgadge/)
- 📧 Email: abhijeetgadge100@gmail.com

---

## 🏷️ License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
