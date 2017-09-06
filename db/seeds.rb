# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Marketplace.create({
                       :name => 'Etsy',
                       :url => 'http://etsy.com',
                       :api_uid => 'etsy'
                   }) unless Marketplace.where(:name => 'Etsy').any?

Marketplace.create({
                       :name => 'Amazon',
                       :url => 'http://amazon.com',
                       :api_uid => 'amazon'
                   }) unless Marketplace.where(:name => 'Amazon').any?

Marketplace.create({
                       :name => 'eBay',
                       :url => 'http://ebay.com',
                       :api_uid => 'ebay'
                   }) unless Marketplace.where(:name => 'eBay').any?

Marketplace.create({
                       :name => 'Shopify',
                       :url => 'http://shopify.com',
                       :api_uid => 'shopify'
                   }) unless Marketplace.where(:name => 'Shopify').any?
