// Airbyte Terraform provider documentation: https://registry.terraform.io/providers/airbytehq/airbyte/latest/docs

// Sources
resource "airbyte_source_postgres" "postgres_src" {
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
        tunnel_method = {
            no_tunnel = {}
        }
        replication_method = {
            scan_changes_with_user_defined_cursor = {}
        }
    }
    name = "Postgres"
    workspace_id = var.workspace_id
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
    name = "Postgres"
    workspace_id = var.workspace_id
}

// Connections
resource "airbyte_connection" "postgres_to_postgres" {
    name = "Postgres to Postgres"
    source_id = airbyte_source_postgres.postgres_src.source_id
    destination_id = airbyte_destination_postgres.postgres_dest.destination_id
    configurations = {
        streams = [
            {
                name = "open_alex"
            },
            {
                name = "airbyte_raw_Core_Data"
            },
        ]
    }
}