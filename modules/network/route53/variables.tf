variable "zone_name" {
  description = "레코드를 생성할 Route 53 호스팅 영역의 이름"
  type        = string
}

variable "record_name" {
  description = "생성할 레코드의 이름 (서브도메인)"
  type        = string
}

variable "target_dns_name" {
  description = "레코드가 가리킬 대상의 DNS 이름 (ALB의 DNS 이름)"
  type        = string
}

variable "target_zone_id" {
  description = "레코드가 가리킬 대상의 호스팅 영역 ID (ALB의 Zone ID)"
  type        = string
}
