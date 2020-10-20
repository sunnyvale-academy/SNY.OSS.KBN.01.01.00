credentials    = "sny-prg-dvs-01-01-00-1a3a462f342a.json"
project_id         = "sny-prg-dvs-01-01-00"
region             = "europe-west4"
zones              = ["europe-west4-a", "europe-west4-b", "europe-west4-c"]
name               = "demo-gke-cluster"
machine_type       = "n1-standard-1"
min_count          = 1
max_count          = 3
disk_size_gb       = 10
service_account    = "terraform1@sny-prg-dvs-01-01-00.iam.gserviceaccount.com"
initial_node_count = 2

