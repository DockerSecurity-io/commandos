target "default" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["flask-hello:latest"]
}