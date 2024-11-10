require 'yaml'

DEBUG_PRINT = false

class MemoryLayoutGen < Asciidoctor::Extensions::IncludeProcessor
  def debug *args
    if DEBUG_PRINT
      puts *args
    end
  end

  def handles? target
    target.end_with? "memory-layout.yaml"
  end

  def generate_table fields
    format = '[%header,frame=all,grid=all,cols="<2m,16*^1m"]'
    header = "|Address|0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f"
    table_rows = generate_table_rows fields

    [format, "|===", header, table_rows, "|==="].join("\n")
  end

  def generate_table_rows fields
    table_rows = ""

    def align address
      if address.nil?
        return nil
      else
        return address / 16 * 16
      end
    end

    prev = (nil..nil)
    remainder = nil

    print_address_field = lambda do |address|
      if not remainder.nil?
        # print the remainder lines. This is its own sub algo,
        # because sometimes a remainder needs to be finished before
        # the next address that is much father away can be processed.
        # Also multiline remainders are mäh
        rows = (align(prev.end) - align(prev.begin))/16

        if rows <= 2
          (1..rows - 1).each do |i|
            table_rows += "\n| %06x 16+<|..." % [align(prev.begin + i * 16)]
            remainder -= 16
          end
        else
          table_rows += "\n"
          table_rows += " 17+<|* (cont)"
          remainder = remainder - align(remainder)

          if remainder == 0
            remainder = 16
          end
        end


        if remainder > 0
          table_rows += "\n| %06x %d+<|..." % [align(prev.end), remainder]
        end
        prev = (align(prev.end)..align(prev.end) + remainder)
        remainder = nil
        debug "Run through remainder (end: %x)" % [prev.end]
      end

      if (align(address) != align(prev.begin))
        debug "doing address %x" % [address]
        if not prev.end.nil?
          table_rows += " | " * ((16 - prev.end) % 16)
        end

        table_rows += "\n"
        if align(address) - (align(prev.begin) || 0) > 16
          table_rows += " 17+<|*\n"
        end

        table_rows += "| %06x" % [align(address)]

        prev = (align(address)..align(address))
      end
    end

    fields.each do |elem|
      # check first if shall print address
      print_address_field.call elem["address"]

      debug elem, prev, table_rows
      # then add offset until element
      table_rows += " | " * (elem["address"] - prev.end) % 16

      # if we do line wrap define remainder
      if align(elem["address"]) != align(elem["address"] + elem["length"])
        remainder = (elem["length"] + elem["address"] - align(elem["address"]) - 16)
        debug "Remainder of: %d" % [remainder]
      end
      # write our value
      table_rows += " %d+<|%s" % [(elem["length"] - (remainder || 0)), elem["shortname"] || elem["name"]]

      prev = (elem["address"]..elem["address"] + elem["length"])
    end

    if not remainder.nil?
      print_address_field.call prev.end
    end

    if not (prev.end.nil? or not remainder.nil?)
      table_rows += " | " * ((16 - prev.end) % 16)
    end

    table_rows
  end

  def process doc, reader, target, attributes
    puts "matched stuff " + target
    data = YAML.load_file target
    fields = data['fields'].sort_by { |f| f['address'] }

    properties = ""
    table = ""

    fields.each do |element|
      order = ""
      case element['order']
        when "LE"
          order = "little endian"
        when "BE"
          order = "big endian"
      end

      properties += "\n"
      if element["ref"]
        properties += "[#%s]" % [element["ref"]]
      end
      properties += "\n==== Offset `0x%06x`: %s" % [element['address'], element['name']]
      if element['shortname']
        properties += " (%s)" % [element['shortname']]
      end
      properties += "\n"
      properties += "> length: %d byte(s)" % [element['length']]
      if order != ""
        properties += " / byte order: %s" % [order]
      end
      properties += "\n\n"
      properties += element['description']
    end

    table = generate_table fields

    reader.push_include ["=== Fields", properties, "<<<", "=== Memory Table", table].join("\n\n"), target, target, 1, attributes
    reader
  end
end

Asciidoctor::Extensions.register do
  include_processor MemoryLayoutGen
end
