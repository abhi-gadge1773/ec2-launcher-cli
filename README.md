# 🚀 EC2 Launcher CLI

A powerful and beginner-friendly Bash script that helps you interactively launch AWS EC2 instances with minimal effort. Automatically handles:

✅ Security group creation (if not provided)  
✅ Subnet detection (from default VPC)  
✅ SSH access from your IP  
✅ Optional automatic login via SSH  
✅ Full logging and color-coded output  

---

## 🔧 Features

- Interactive CLI menu to launch EC2 instances
- Auto-creates a security group if none is provide
---

## 🚀 Getting Started

### 1. ✅ Prerequisites

- AWS CLI configured (`aws configure`)
- A valid key pair already created in EC2 console
- IAM permissions to launch EC2 and create security groups
- `jq` and `curl` installed

### 2. 💻 Run the Script

```bash
git clone https://github.com/your-username/ec2-launcher-cli.git
cd ec2-launcher-cli

chmod +x ec2-launcher.sh
./ec2-launcher.sh
d
- Detects your default VPC's subnet if none is entered
- Waits until instance is in running state
- Fetches and displays public IP, state, and launch time
- Prompts you to SSH into the instance automatically

---



