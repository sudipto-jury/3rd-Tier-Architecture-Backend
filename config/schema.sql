-- AWS Learn Database Schema
-- Run this file in your PostgreSQL database to set up all tables

-- Create database (run this separately if needed)
-- CREATE DATABASE awslearn;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  avatar VARCHAR(10) DEFAULT '🎓',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- AWS Services table (pre-populated)
CREATE TABLE IF NOT EXISTS services (
  id SERIAL PRIMARY KEY,
  slug VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10) NOT NULL,
  category VARCHAR(50) NOT NULL,
  short_description TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Topics / Sections within each service
CREATE TABLE IF NOT EXISTS topics (
  id SERIAL PRIMARY KEY,
  service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- User progress tracking
CREATE TABLE IF NOT EXISTS user_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
  topic_id INTEGER REFERENCES topics(id) ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  UNIQUE(user_id, topic_id)
);

-- Questions / Comments per service
CREATE TABLE IF NOT EXISTS questions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  service_id INTEGER REFERENCES services(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer TEXT,
  answered_by INTEGER REFERENCES users(id),
  answered_at TIMESTAMP,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Question likes (to prevent duplicate likes)
CREATE TABLE IF NOT EXISTS question_likes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
  UNIQUE(user_id, question_id)
);

-- Seed AWS Services
INSERT INTO services (slug, name, icon, category, short_description) VALUES
('ec2', 'Amazon EC2', '💻', 'Compute', 'Elastic Compute Cloud - Scalable virtual servers in the cloud'),
('s3', 'Amazon S3', '🗄️', 'Storage', 'Simple Storage Service - Object storage built to retrieve any amount of data'),
('route53', 'Amazon Route 53', '🌐', 'Networking', 'Scalable DNS and domain name registration service'),
('cloudfront', 'Amazon CloudFront', '⚡', 'Networking', 'Fast content delivery network (CDN) service'),
('cloudwatch', 'Amazon CloudWatch', '📊', 'Management', 'Monitoring and observability service for AWS resources'),
('vpc', 'Amazon VPC', '🔒', 'Networking', 'Virtual Private Cloud - Isolated virtual network in AWS'),
('iam', 'AWS IAM', '🛡️', 'Security', 'Identity and Access Management - Control access to AWS services')
ON CONFLICT (slug) DO NOTHING;

-- Seed EC2 Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(1, 'What is Amazon EC2?', 
'Amazon Elastic Compute Cloud (Amazon EC2) is a web service that provides secure, resizable compute capacity in the cloud. It is designed to make web-scale cloud computing easier for developers.

EC2 allows you to obtain and configure capacity with minimal friction. It provides you with complete control of your computing resources and lets you run on Amazon''s proven computing environment.

**Key Benefits:**
- Elastic Web-Scale Computing
- Completely Controlled
- Flexible Cloud Hosting Services
- Integrated with AWS Services
- Reliable, Scalable Infrastructure
- Secure
- Inexpensive', 1),

(1, 'EC2 Instance Types',
'EC2 offers a wide selection of instance types optimized to fit different use cases. Instance types comprise varying combinations of CPU, memory, storage, and networking capacity.

**General Purpose (t3, m5, m6i):**
Balance of compute, memory, and networking. Good for web servers and small databases.

**Compute Optimized (c5, c6i):**
High-performance processors. Ideal for batch processing, media transcoding, and high-performance web servers.

**Memory Optimized (r5, x1):**
Fast performance for workloads that process large data sets in memory. Great for high-performance databases.

**Storage Optimized (i3, d2):**
High, sequential read/write access to large datasets. Good for NoSQL databases and data warehousing.

**Accelerated Computing (p3, g4):**
Hardware accelerators (GPUs). Machine learning, graphics workloads.', 2),

(1, 'EC2 Pricing Models',
'Amazon EC2 provides several purchasing options to optimize costs:

**On-Demand Instances:**
Pay for compute capacity per hour with no long-term commitments. Best for short-term, irregular workloads.

**Reserved Instances:**
Provide a significant discount (up to 72%) compared to On-Demand pricing. Commit to 1 or 3-year term.

**Spot Instances:**
Request spare EC2 computing capacity for up to 90% off the On-Demand price. Best for fault-tolerant and flexible workloads.

**Dedicated Hosts:**
Physical EC2 server dedicated for your use. Helps with compliance requirements.

**Savings Plans:**
Flexible pricing model offering up to 72% savings on compute usage.', 3),

(1, 'EC2 Security Groups',
'Security Groups act as a virtual firewall for your EC2 instances to control incoming and outgoing traffic.

**Key Features:**
- Stateful: Return traffic is automatically allowed
- Rules are always permissive — cannot create deny rules
- Changes take effect immediately
- Multiple security groups can be assigned to an instance

**Inbound Rules:** Control the incoming traffic to your instance
**Outbound Rules:** Control the outgoing traffic from your instance

**Best Practices:**
- Follow the principle of least privilege
- Use separate security groups for different tiers (web, app, db)
- Regularly audit and clean up unused rules
- Avoid allowing 0.0.0.0/0 on sensitive ports', 4);

-- Seed S3 Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(2, 'What is Amazon S3?',
'Amazon Simple Storage Service (Amazon S3) is an object storage service offering industry-leading scalability, data availability, security, and performance.

S3 stores data as objects within buckets. An object consists of a file and optionally any metadata that describes that file.

**Use Cases:**
- Backup and restore
- Disaster recovery
- Archive
- Data lakes and big data analytics
- Hybrid cloud storage
- Cloud-native application hosting
- Static website hosting', 1),

(2, 'S3 Storage Classes',
'S3 offers a range of storage classes designed for different use cases:

**S3 Standard:**
General-purpose storage for frequently accessed data. High durability, availability, and performance.

**S3 Intelligent-Tiering:**
Automatically moves data to most cost-effective access tier. No retrieval charges.

**S3 Standard-IA (Infrequent Access):**
Long-lived, infrequently accessed data. Lower cost than Standard, but retrieval fee applies.

**S3 Glacier:**
Low-cost storage for data archiving. Retrieval times from minutes to hours.

**S3 Glacier Deep Archive:**
Lowest cost storage for long-term retention. Retrieval time of 12 hours.

**Durability:** All classes provide 99.999999999% (11 9s) durability.', 2),

(2, 'S3 Bucket Policies and Security',
'S3 provides multiple layers of security to protect your data:

**Bucket Policies:**
Resource-based policies that control access to your bucket and objects. Written in JSON.

**Access Control Lists (ACLs):**
Legacy access control mechanism. Define who can access the bucket and what actions they can perform.

**S3 Block Public Access:**
Account-level or bucket-level settings to block all public access. Enabled by default.

**Encryption:**
- Server-Side Encryption with S3 Keys (SSE-S3)
- Server-Side Encryption with KMS Keys (SSE-KMS)
- Server-Side Encryption with Customer Keys (SSE-C)
- Client-Side Encryption

**Versioning:**
Keep multiple variants of an object in the same bucket. Protects against accidental deletion.', 3);

-- Seed VPC Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(6, 'What is Amazon VPC?',
'Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define.

You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.

**Key Components:**
- Subnets (Public & Private)
- Route Tables
- Internet Gateway
- NAT Gateway
- Security Groups
- Network ACLs', 1),

(6, 'Subnets and CIDR Blocks',
'A subnet is a range of IP addresses in your VPC. You can launch AWS resources into a specified subnet.

**Public Subnet:**
Has a route to an Internet Gateway. Resources can communicate with the internet directly.

**Private Subnet:**
Does not have a route to an Internet Gateway. Resources cannot directly communicate with the internet.

**CIDR Notation:**
Classless Inter-Domain Routing — a way to express IP address ranges.
Example: 10.0.0.0/16 gives you 65,536 addresses
Example: 10.0.1.0/24 gives you 256 addresses

**Best Practice Architecture:**
- Put web servers in public subnets
- Put databases and app servers in private subnets
- Use NAT Gateway to allow private instances to reach internet
- Deploy across multiple Availability Zones for high availability', 2);

-- Seed IAM Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(7, 'What is AWS IAM?',
'AWS Identity and Access Management (IAM) enables you to manage access to AWS services and resources securely. Using IAM, you can create and manage AWS users and groups, and use permissions to allow and deny their access to AWS resources.

**Core Concepts:**
- **Users:** Individual people or services with long-term credentials
- **Groups:** Collection of users with shared permissions
- **Roles:** Temporary credentials for AWS services or federated users
- **Policies:** JSON documents defining permissions

IAM is global — not region-specific.', 1),

(7, 'IAM Policies and Permissions',
'IAM policies are JSON documents that define permissions. They specify what actions are allowed or denied on which resources.

**Policy Structure:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

**Types of Policies:**
- **AWS Managed Policies:** Created and managed by AWS
- **Customer Managed Policies:** Created by you in your account
- **Inline Policies:** Embedded directly in a user, group, or role

**Principle of Least Privilege:** Grant only the permissions required to perform the task. Start with minimum permissions and grant more as needed.', 2),

(7, 'IAM Best Practices',
'Follow these best practices to secure your AWS account:

1. **Lock Away Root User Access Keys** — Never use root for daily tasks
2. **Create Individual IAM Users** — One person = one IAM user
3. **Use Groups for Permissions** — Assign permissions to groups, not individuals
4. **Grant Least Privilege** — Start with minimum permissions
5. **Enable MFA** — Multi-Factor Authentication for privileged users
6. **Use Roles for Applications** — EC2 instances should use IAM Roles, not embedded credentials
7. **Rotate Credentials Regularly** — Change access keys periodically
8. **Use IAM Access Analyzer** — Identify resources shared with external entities
9. **Monitor Activity with CloudTrail** — Log all API calls
10. **Use Conditions in Policies** — Add extra constraints like IP restriction or MFA requirement', 3);

-- Seed CloudWatch Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(5, 'What is Amazon CloudWatch?',
'Amazon CloudWatch is a monitoring and observability service built for DevOps engineers, developers, site reliability engineers (SREs), and IT managers.

CloudWatch provides you with data and actionable insights to monitor your applications, respond to system-wide performance changes, optimize resource utilization, and get a unified view of operational health.

**Key Features:**
- **Metrics:** Time-ordered data points from your resources
- **Logs:** Collect, monitor, and store log files
- **Alarms:** Trigger actions based on metric thresholds
- **Dashboards:** Customizable home pages in the CloudWatch console
- **Events:** Stream of system events describing changes in AWS resources', 1),

(5, 'CloudWatch Metrics and Alarms',
'Metrics are the fundamental concept in CloudWatch. They represent a time-ordered set of data points published to CloudWatch.

**Default EC2 Metrics (1-minute intervals):**
- CPUUtilization
- DiskReadOps / DiskWriteOps
- NetworkIn / NetworkOut
- StatusCheckFailed

**Custom Metrics:**
You can publish your own metrics from your applications using the PutMetricData API.

**CloudWatch Alarms:**
Watch a single metric over a specified time period and performs actions:
- **OK:** Metric is within the defined threshold
- **ALARM:** Metric is outside the defined threshold
- **INSUFFICIENT_DATA:** Not enough data

**Alarm Actions:**
- Send SNS notification
- Auto Scaling action
- EC2 action (stop, terminate, reboot)', 2);

-- Seed Route53 Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(3, 'What is Amazon Route 53?',
'Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service. It is designed to give developers and businesses an extremely reliable and cost-effective way to route end users to Internet applications.

The name "Route 53" refers to the TCP and UDP port 53, where DNS server requests are addressed.

**Key Features:**
- Domain Registration
- DNS Routing
- Health Checking
- Traffic Flow
- Latency-based Routing
- Geolocation Routing
- Failover Routing', 1),

(3, 'Route 53 Routing Policies',
'Route 53 supports several routing policies:

**Simple Routing:**
Single resource for a domain. No health checks. Most basic policy.

**Weighted Routing:**
Route traffic to multiple resources based on percentage weights. Great for A/B testing and blue/green deployments.

**Latency-based Routing:**
Route to the region with the lowest latency for the user. Improves global performance.

**Failover Routing:**
Active-passive failover. Route to primary resource unless it''s unhealthy, then failover to secondary.

**Geolocation Routing:**
Route based on the geographic location of users (continent, country, or US state).

**Geoproximity Routing:**
Route based on geographic location with optional traffic bias.

**Multi-value Answer:**
Return multiple IP addresses and let clients pick. Basic load balancing with health checks.', 2);

-- Seed CloudFront Topics
INSERT INTO topics (service_id, title, content, order_index) VALUES
(4, 'What is Amazon CloudFront?',
'Amazon CloudFront is a fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency, high transfer speeds.

CloudFront is integrated with AWS — both physical locations that are directly connected to the AWS global infrastructure, as well as other AWS services.

**Key Benefits:**
- Global Edge Network (410+ Points of Presence)
- Integrated with AWS Shield for DDoS protection
- Works seamlessly with S3, EC2, ELB
- SSL/TLS encryption
- Real-time metrics and logging
- Cost-effective — pay only for data transferred', 1),

(4, 'CloudFront Distributions and Origins',
'A CloudFront distribution tells CloudFront where you want content to be delivered from and the details about how to track and manage content delivery.

**Origins:**
The place where the original, definitive version of your content is stored.
- **S3 Bucket:** For distributing files and caching them at the edge
- **EC2 Instance:** For dynamic content
- **Elastic Load Balancer:** For load-balanced applications
- **Custom HTTP Server:** Any HTTP server

**Edge Locations:**
Data centers where content is cached. Much more numerous than Availability Zones.

**Cache Behavior:**
Settings that tell CloudFront how to handle requests:
- Path patterns
- Cache TTL (Time To Live)
- Allowed HTTP methods
- Compress objects automatically
- Restrict viewer access (signed URLs)', 2);

COMMIT;
