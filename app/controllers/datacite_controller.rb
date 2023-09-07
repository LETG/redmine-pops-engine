class DataciteController < ApplicationController
  def search
    min_words = 2
    query     = params[:query].split(" ")

    if query.count < min_words
      @warning_message = "Vous devez saisir au moins #{min_words} mots pour rechercher les documents Datacite"
    else
      source = "https://api.datacite.org/dois"
      articles = []
      response = JSON.load(open(URI.encode("#{source}?query=#{query.join(' AND ')}")))
      @results = response["data"].inject([]) do |a, data|
        a << datacite_doi(data)
        a
      end

      @meta    = response["meta"]
    end
    
    respond_to do |format|
      format.json { return render partial: 'documents/datacite/results', formats: [ :html ] }
    end
  end

  private
    def datacite_doi(data)
      article = {}
      
      title      = data.dig(*"attributes.titles".split(".")).select { |t| t["lang"] == 'fre' }.first rescue nil
      title    ||= data.dig(*"attributes.titles".split(".")).select { |t| t["lang"] == '' }.first rescue nil
      title    ||= data.dig(*"attributes.titles".split(".")).first rescue nil

      abstract   = data.dig(*"attributes.descriptions".split(".")).select { |t| t["lang"] == 'fre' }.first rescue nil
      abstract ||= data.dig(*"attributes.descriptions".split(".")).select { |t| t["lang"] == '' }.first rescue nil
      abstract ||= data.dig(*"attributes.descriptions".split(".")).first rescue nil

      article[:id]           = data["id"]
      article[:title]        = title['title']
      article[:abstract]     = abstract['description'] rescue nil
      article[:creators]     = data.dig(*"attributes.creators".split(".")).inject([]) do |a, c|
        a << { name: c["name"], affiliations: Array.wrap(c["affiliations"]).uniq }
        a
      end

      article[:url]          = data.dig(*"attributes.url".split("."))
      article[:publisher]    = data.dig(*"attributes.publisher".split("."))
      article[:published_at] = Time.parse(data.dig(*"attributes.created".split("."))) rescue nil

      OpenStruct.new(article)
    end
end