data "sops_file" "secrets" {
  source_file = "secrets.yaml"
  input_type  = "yaml"
}
