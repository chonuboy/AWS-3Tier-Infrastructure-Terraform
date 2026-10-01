<!-- Complete Architecture -->

                    ┌──────────────────┐
                    │    Internet      │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Internet Gateway │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
       Public Subnet A               Public Subnet B
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │       ALB        │
                    │    HTTP : 80     │
                    └────────┬─────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
                    ▼                  ▼
             Private App A       Private App B
                    │                  │
                 EC2 #1             EC2 #2
                    │                  │
                    └────────┬─────────┘
                             │
                        NAT Gateway
                             │
                             ▼
                       Internet Gateway

<!-- Database Tier -->

             Private App Tier
                    │
                    │ MySQL :3306
                    ▼
          ┌──────────────────────┐
          │    Private DB Tier   │
          │                      │
          │       RDS MySQL      │
          └──────────────────────┘