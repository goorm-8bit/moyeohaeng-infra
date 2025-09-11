# 1. Route 53 호스팅 영역 정보 가져오기
data "aws_route53_zone" "this" {
  name = var.zone_name
}

# 2. DNS 레코드 생성
resource "aws_route53_record" "this" {
  name    = "${var.record_name}.${var.zone_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  # A 레코드 대신 AWS 리소스를 직접 가리키도록 하는 설정
  # IP 주소가 변경되어도 자동으로 추적
  alias {
    evaluate_target_health = true
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
  }
}
