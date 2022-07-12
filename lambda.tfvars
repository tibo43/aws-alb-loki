retention_in_days=1
functions = {
    alb-production = {
        schedule = "cron(0/5 * * * ? *)"
        is_enabled = true
        variables = {
            AWS_S3_BUCKET="aws_bucket_logs"
            LOKI_URL="https://url.loki:port/loki/api/v1/push"
            ENVIRONMENT="product-production"
            MARKER_FILENAME="alb-product-production"
        }
        timeout=420
        memory_size=128
        team        = "devops"
        product     = "product"
        department  = "tech"
        environment = "production"
    },
    alb-staging = {
        schedule = "cron(0/5 * * * ? *)"
        is_enabled = true
        variables = {
            AWS_S3_BUCKET="aws_bucket_logs"
            LOKI_URL="https://url.loki:port/loki/api/v1/push"
            ENVIRONMENT="product-staging"
            MARKER_FILENAME="alb-product-staging"
        }
        timeout=420
        memory_size=128
        team        = "devops"
        product     = "product"
        department  = "tech"
        environment = "staging"
    },
}