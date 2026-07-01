## Terraform AWS Project

A Terraform project that sets up a simple web hosting setup on AWS — two web servers behind a load balancer, all inside a private network.

---

## What This Project Creates

| Resource | What it is |
|---|---|
| VPC | A private network on AWS to keep everything together |
| 2 Subnets | Two sections of the network in different locations for reliability |
| Internet Gateway | Allows the network to connect to the internet |
| Route Table | Directs traffic to the right place |
| Security Group | Controls what traffic is allowed in and out (port 80 and 22) |
| 2 EC2 Instances | Two web servers, one in each subnet |
| S3 Bucket | Storage bucket |
| Load Balancer | Splits incoming traffic between the two web servers |

---

## How It Works

1. Terraform creates a VPC with two subnets in different availability zones
2. Two EC2 instances are launched — one in each subnet — with a web server set up automatically using `userdata.sh` and `userdata1.sh`
3. A load balancer sits in front of both instances and shares the incoming traffic between them
4. At the end, Terraform prints out the load balancer URL so you can open it in a browser

---

## Files

| File | What it does |
|---|---|
| `main.tf` | Creates all the AWS resources |
| `provider.tf` | Tells Terraform to use AWS |
| `variables.tf` | Stores values like region, AMI, and instance type |
| `userdata.sh` | Script that runs on the first EC2 instance when it starts |
| `userdata1.sh` | Script that runs on the second EC2 instance when it starts |

---

## Architecture

![Architecture](https://raw.githubusercontent.com/Kalvakota-Divakar/Terraform-aws-project/main/Infra.png)

---

## How to Run

```bash
git clone https://github.com/Kalvakota-Divakar/Terraform-aws-project.git
cd Terraform-aws-project
```

```bash
terraform init
terraform plan
terraform apply
```

Once done, Terraform will print the load balancer URL:

```
loadbalancerdns = "myalb-xxxxxxxxxx.us-east-1.elb.amazonaws.com"
```

Open that URL in your browser to see the web servers responding.

To delete everything when you're done:

```bash
terraform destroy
```

---

## Requirements

- Terraform installed
- AWS credentials configured (`aws configure`)

---

## Author

**Kalvakota Divakar**
- GitHub: https://github.com/Kalvakota-Divakar
- LinkedIn: https://www.linkedin.com/in/kalvakota-divakar

---

## License

MIT
