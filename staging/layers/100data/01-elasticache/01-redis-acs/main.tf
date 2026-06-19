module "acs_redis" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/elasticache/redis/acs?ref=fix/redis_mod"
  env    = local.env

  name                            = local.name
  description                     = local.description
  engine_version                  = local.engine_version
  instance_type                   = local.instance_type
  additional_security_group_rules = local.additional_security_group_rules

  elasticache_users = {
    portalwebsocketapp = {
      access_string = "on ~* +@all"
    }
    portalrestapp = {
      access_string = "on ~* +@all"
    }
    scheduleeventengineapp = {
      access_string = "on ~* +@all"
    }
    riskengineapp = {
      access_string = "on ~* +@all"
    }
    priceengineapp = {
      access_string = "on ~* +@all"
    }
    intradayclearengineapp = {
      access_string = "on ~* +@all"
    }
    eodclearengineapp = {
      access_string = "on ~* +@all"
    }
    exberryt2cgatewayapp = {
      access_string = "on ~* +@all"
    }
    dbmsingestorapp = {
      access_string = "on ~* +@all"
    }
  }
}
