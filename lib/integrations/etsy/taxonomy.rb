module Integrations::Etsy

  class Taxonomy

    def initialize(json)
      @categories = []

      traverse_taxonomy_tree(json, 'results') do |parent_node|
        unless parent_node.equal?(json)
          @categories <<
              {
                  parent_id: parent_node['parent_id'],
                  id: parent_node['id'],
                  name: parent_node['name'],
                  has_children: parent_node['children'].count > 0
              }
        end
      end
    end

    def find_all_subcategories(parent_id = nil)
      @categories.find_all { |category| category[:parent_id] == parent_id }
    end

    private

    def traverse_taxonomy_tree(parent_node, children_node_name = 'children', &block)
      return unless parent_node && block_given?

      yield parent_node

      parent_node[children_node_name].each { |child_node| traverse_taxonomy_tree(child_node, &block) }
    end
  end
end
