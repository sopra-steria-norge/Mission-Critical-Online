resource "azurerm_redis_enterprise_cluster" "global_replicas" {
  for_each            = toset(var.stamps)
  name                = "example-redisenterprise"
  resource_group_name = azurerm_resource_group.global.name
  location            = each.value

  sku_name = "Enterprise_E20-4"
}

resource "azurerm_redis_enterprise_database" "default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.global.name

  cluster_id        = azurerm_redis_enterprise_cluster.global_replicas.0.id
  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster"
  eviction_policy   = "NoEviction"
  port              = 10000

  linked_database_id = [for instance in var.stamps : "${azurerm_redis_enterprise_cluster.global_replicas[instance.key].id}/databases/default"]

  linked_database_group_nickname = "tftestGeoGroup"
}