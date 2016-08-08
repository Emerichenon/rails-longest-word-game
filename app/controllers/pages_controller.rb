require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = []
    10.times do
      @grid << ("a".."z").to_a.sample
    end
    @start_time = Time.now
  end

  def score
    @user_word = params[:user_word]
    @grid = params[:grid].split("")
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now

    @grid.map!(&:downcase)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{@user_word}"
    my_data_json = open(api_url).read
    parsed_data = JSON.parse(my_data_json)
    grid_to_compare = @grid.sort
    @hash_final = {}

    if parsed_data == { "Error" => "NoTranslation", "Note" => "No translation was found for #{@user_word}.\nAucune traduction trouvée pour #{@user_word}." }
      @hash_final[:message] = "not an english word"
      @hash_final[:score] = 0
    elsif @user_word.downcase.split("").sort.all? { |letter| (@user_word.scan(letter.to_s).count <= grid_to_compare.join.scan(letter).count) && grid_to_compare.include?(letter) }
      # Extraire la traduction et la mettre dans le hash
      @hash_final[:translation] = parsed_data["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      # Compter nombre de lettre et score par lettre
      @hash_final[:score] = @user_word.length * 100
      # Compter le temps et score lie au temps
      @hash_final[:time] = @end_time - @start_time
      @hash_final[:score] -= @hash_final[:time]
      # Definir le bon message
      @hash_final[:message] = "well done"
    else
      @hash_final[:score] = 0
      @hash_final[:message] = "not in the grid"
    end
    increment_counter
    session[:score] += @hash_final[:score]
  end

  def increment_counter
    if session[:counter].nil?
      session[:counter] = 0
    else
    session[:counter] += 1
    end
    if session[:score].nil?
      session[:score] = 0
    end
  end
end


# RRRR \


# def run_game(attempt, grid, start_time, end_time)
#   # TODO: runs the game and return detailed hash of result
#   grid.map!(&:downcase)
#   api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
#   my_data_json = open(api_url).read
#   parsed_data = JSON.parse(my_data_json)
#   grid_to_compare = grid.sort
#   hash_final = {}

#   if parsed_data == { "Error" => "NoTranslation", "Note" => "No translation was found for #{attempt}.\nAucune traduction trouvée pour #{attempt}." }
#     hash_final[:message] = "not an english word"
#     hash_final[:score] = 0
#   elsif attempt.downcase.split("").sort.all? { |letter| (attempt.scan(letter.to_s).count <= grid_to_compare.join.scan(letter).count) && grid_to_compare.include?(letter) }
#     # Extraire la traduction et la mettre dans le hash
#     hash_final[:translation] = parsed_data["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
#     # Compter nombre de lettre et score par lettre
#     hash_final[:score] = attempt.length * 100
#     # Compter le temps et score lie au temps
#     hash_final[:time] = end_time - start_time
#     hash_final[:score] -= hash_final[:time]
#     # Definir le bon message
#     hash_final[:message] = "well done"
#   else
#     hash_final[:score] = 0
#     hash_final[:message] = "not in the grid"
#   end
#   return hash_final
# end
