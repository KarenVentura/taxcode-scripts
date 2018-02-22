require 'pry'
require 'nokogiri'

class XmlGenerator

  def initialize(file_name)
    @file_name = file_name
  end

  def build_xml
    @document = read
    products = get_products_with_tax_code

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml|
      xml.catalog('xmlns' => 'http://www.demandware.com/xml/impex/catalog/2006-10-31', 'catalog-id' => 'henribendel-master') do
        add_product_attribute(products, xml)
      end
    }

    export_file(builder)
  end

  def read
    File.open(@file_name) { |f| Nokogiri::XML(f) }
  end

  def get_products_with_tax_code
    products = {}

    @document.search('product').each do |product|
      next if product.search('tax-class-id').none?
      tax_code = product.search('tax-class-id').text
      product_id = product.attributes['product-id'].text
      new_tax_code = map_tax_code(tax_code)
      products[product_id] = new_tax_code
    end

    products
  end

  def map_tax_code(tax_code)
    TAX_CODES[tax_code] unless TAX_CODES[tax_code].nil?
  end

  def add_product_attribute(products, xml)
    products.each do |product|
      unless product[1].nil?
        xml.send('product', 'product-id' => product[0]) do
          xml.send('tax-class-id', product[1])
        end
      end
    end
  end

  def export_file(builder)
    filename = 'catalog.xml'
    File.read(filename)
    File.write(filename, builder.to_xml)
  end
end

XmlGenerator.new('wrong_product_taxes.xml').build_xml
TAX_CODES = {'PF050500'  => '75200','PF050300'  => '75020','PB100200'  => '73110','PC040100'  => '61000','224'       => '9300','PF050700'  => '75090','ESW'       => '6190','NT'        => '6190','PC040144'  => '61025','PG050000'  => '61901','PH050500'  => '76085','PH050117'  => '76030','PF050314'  => '75028','PN030000'  => '73112','PF050200'  => '75035','PC040200'  => '61700','PS060100'  => '61915','PM030110'  => '73104','FR020800'  => '43000','P0000000'  => '76800','PC040106'  => '61605','SC060000'  => '61905','101'       => '1844'}
