resource "random_pet" "master" {
  # prefix = "master"
  count  = "${(var.count + 50)}"
  length = 1
}

# resource "random_pet" "slave" {
#   # prefix = "worker"
#   count  = "${(var.count / 2) + 20}"
#   length = 1
# }

