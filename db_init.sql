CREATE TABLE IF NOT EXISTS "categories" (
  "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  "name" varchar NOT NULL,
  "url" varchar NOT NULL,
  "last_page_scraped" integer default 0,
  "last_scraped_at" datetime
);

INSERT INTO "categories" (name, url) values
("all", "https://apps.shopify.com/browse/all"),
("store-design", "https://apps.shopify.com/browse/store-design"),
("conversion", "https://apps.shopify.com/browse/conversion"),
("marketing", "https://apps.shopify.com/browse/marketing"),
("store-management", "https://apps.shopify.com/browse/store-management"),
("fulfillment", "https://apps.shopify.com/browse/fulfillment"),
("customer-service", "https://apps.shopify.com/browse/customer-service"),
("merchandising", "https://apps.shopify.com/browse/merchandising"),
("shipping-and-delivery", "https://apps.shopify.com/browse/shipping-and-delivery"),
("sourcing-and-selling-products", "https://apps.shopify.com/browse/sourcing-and-selling-products");

CREATE TABLE IF NOT EXISTS "application_links" (
  "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  "url" varchar NOT NULL,
  "last_seen_in_category" datetime,
  "last_scraped_at" datetime
);
CREATE UNIQUE INDEX IF NOT EXISTS "index_application_links_url" ON "application_links" ("url");


CREATE TABLE IF NOT EXISTS "application_snapshots" (
  "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  "application_link_id" integer NOT NULL,
  "name" varchar,
  "one_star" integer,
  "two_stars" integer,
  "three_stars" integer,
  "four_stars" integer,
  "five_stars" integer,
  "created_at" datetime,
  FOREIGN KEY ("application_link_id") REFERENCES "application_links" ("id")
);
CREATE INDEX IF NOT EXISTS "index_snapshots_on_link_id" ON "application_snapshots" ("link_id");

CREATE TABLE IF NOT EXISTS "application_snapshots_categories" (
  "application_snapshot_id" integer NOT NULL,
  "category_id" integer NOT NULL
);
