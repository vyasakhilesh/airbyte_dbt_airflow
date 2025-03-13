// Airbyte Terraform provider documentation: https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs

// Sources
resource "airbyte_source_mongodb_v2" "mongodbv2" {
  configuration = {
    database_config = {
      mongo_db_atlas_replica_set = {
        additional_properties = "{ \"see\": \"documentation\" }"
        auth_source           = "admin"
        connection_string     = "mongodb+srv://cluster0.ay0tl.mongodb.net/"
        database              = "article_db"
        password              = var.db_password
        schema_enforced       = false
        username              = "akhvyas"
      }
    }
    discover_sample_size                 = 10000
    initial_load_timeout_hours           = 8
    initial_waiting_seconds              = 300
    invalid_cdc_cursor_position_behavior = "Fail sync"
    queue_size                           = 40
    update_capture_mode                  = "Lookup"
  }
  name          = "Mongodb_Src"
  workspace_id  = var.workspace_id
}

// Destinations
resource "airbyte_destination_postgres" "postgres_dest" {
    configuration = {
        database = "article_db"
        host = "postgres_db"
        username = "admin"
        password = "password"
        port = 5432
        source_type = "postgres"
        schemas = [
            "public"
        ]
        ssl_mode = {
            disable = {}
        }
        ssh_tunnel_method = {
            no_tunnel = {}
        }
        replication_method = {
            scan_changes_with_user_defined_cursor = {}
        }
    }
    name = "Postgres_Dest"
    workspace_id = var.workspace_id
}

// Connections
resource "airbyte_connection" "mongodbv2_to_postgres" {
    name = "Mongodbv2 to Postgres"
    source_id = airbyte_source_mongodb_v2.mongodbv2.source_id
    destination_id = airbyte_destination_postgres.postgres_dest.destination_id
    configurations = {
        streams = [
            {
                name = "airbyte_raw_Core_Data"
            },
            {
                name = "open_alex"
            },
        ]
    }
}