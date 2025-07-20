# 🚀 EC2 Launcher – Shell Scripting Project

An interactive and user-friendly Bash script to **launch EC2 instances on AWS**.  
Ideal for DevOps beginners and automation enthusiasts using **shell scripting**.

This script simplifies the EC2 creation process with:

✅ Automatic security group creation  
✅ Subnet detection from default VPC  
✅ SSH access from your IP  
✅ Auto SSH login prompt after instance launch  
✅ Logging, error handling, and color-coded output

---

## 📁 Project Structure
---

## 🚀 How to Use

### 1. ✅ Prerequisites

- AWS CLI configured (`aws configure`)
- A key pair created in EC2 console (e.g., `MyKey`)
- `jq` and `curl` installed in your environment
- Proper IAM permissions (EC2, VPC, SG)

### 2. 🖥️ Run the Script

```bash
chmod +x ec2-launcher.sh
./ec2-launcher.sh


shell-scripting/
├── ec2-launcher.sh # Main script to launch EC2 instances
├── MyKey.pem # Your local SSH private key (not uploaded to GitHub!)
├── ec2_creation.log # Auto-generated log of created instances
└── README.md # This documentation

🛠 Features
Interactive prompts (AMI, instance type, key pair, etc.)

Automatically creates a security group if none is entered

Automatically detects subnet from default VPC

Waits for instance to become running

Displays instance details (Public IP, State, Launch Time)

Logs output to ec2_creation.log

Optional: SSH into the instance after creation

🙋‍♂️ Author
Abhijeet Gadge
🔗 LinkedIn
🐙 GitHub



