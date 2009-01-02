CREATE TABLE "networks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "text" varchar(255), "medium" varchar(255), "wireless_security" varchar(255) DEFAULT 'none', "wireless_key" varchar(255), "ip_method" varchar(255) DEFAULT 'dhcp', "ip_address" varchar(255), "ip_netmask" varchar(255), "ip_gateway" varchar(255), "ip_domain" varchar(255), "ip_dnsservers" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "radio_streams" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "location" varchar(255), "text" varchar(255), "title" varchar(255), "creator" varchar(255), "annotation" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "index_networks_on_name" ON "networks" ("name");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
