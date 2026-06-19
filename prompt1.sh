Read the following stories from docs/jira-backlog.md:
PetclinicPlatform6: Create VPC module
PetclinicPlatform8: Create baseline security groups
PetclinicPlatform9: Wire VPC module into dev
PetclinicPlatform10: Wire VPC module into prod

Read the technical spec at docs/technical-spec.md, specifically:

VPC Network Design section
Security Groups section
Terraform Modules section
Build everything these stories require. Follow the acceptance criteria exactly.
After you are done, run terraform validate in both dev and prod.
Then use the terraform-reviewer agent to review the module and the security-auditor agent for security and best practices.

Fix any issues the reviewers find, then validate again.


