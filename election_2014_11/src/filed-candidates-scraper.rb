#
# Produces a CSV of candidates that have filed with
# the Austin City Clerk office.
#

require 'nokogiri'
require 'open-uri'
require "csv"

INPUT = "http://austintexas.gov/cityclerk/elections/ballotapplications2014.html"
#INPUT = "ballotapplications2014.html"

COLS = ["Position", "Candidate Name", "First Name", "Last Name", "Date Filed", "Candidate Contract Filed?", "Filings Link"]

def extract_place(field)
    return "Mayor" if field =~ /^Mayor/
    return $1 if field =~ /^District ([0-9]+)/
    nil
end

# Name field format is:
#
#   last, first "nick"
#
# Where nickname is optional.
#
def extract_names(field)
    field.strip.gsub(/\s+/, " ") =~ /(.*), (.*)/ or raise "cannot parse name \"#{field}\""
    last = $1.strip
    first = $2.strip
    if first =~ /"(.*)"$/
        nick = $1.strip
        [nick, last]
    else
        first.sub!(/ \([[[:alpha:]]]+\.\)$/, "") # "Jane (Jr.)" => "Jane"
        first.sub!(/ [[:alpha:]]\.$/, "") # "John Q." => "John"
        [first, last]
    end
end

open(INPUT) do |f|

    place = nil

    doc = Nokogiri::HTML(f) or raise "nokogiri failed to load document"
    edims = doc.xpath('//div[@id="edims"]') or raise "failed to find @id=\"edims\""

    puts COLS.to_csv

    edims.xpath('(h3 | table/tr)').each do |n|
        case n.name
        when "h3"
            # Strip " (spanish)" from end, literal "District" from front.
            # Should leave either "Mayor" or a district number.
            place = extract_place(n.content)
        when "tr"
            next unless place
            candidate = n.xpath("./td/p")
            raise "cannot process table row: #{candidate}" unless candidate.length == 4
            next if (candidate[0].content == "Candidate") # skip header

            row = [place]
            row << candidate[0].content                         # Candidate Name
            row += extract_names(candidate[0].content)          # First, Last
            row << candidate[1].content                         # Date Filed
            # Unicode \u2611 is ☑ (checked box)
            row << !! (candidate[2].content =~ /^\u2611/)       # Contract Filed?
            row << candidate[3].xpath("a").attr("href").value   # Filings Link

          puts row.to_csv

        else
            raise "unexpected HTML element \"#{n.name}\""
        end

    end

end

puts ["# Source", INPUT].to_csv
puts ["# Generated", Time.now].to_csv
