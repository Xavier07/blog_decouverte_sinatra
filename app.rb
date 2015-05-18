require 'sinatra'
# require 'sinatra/reloader' if development?
require 'haml'

#
# Configuration de l'application
#
configure do
  # Accessibles ensuite via settings.views et settings.lyrics 
  set :views,  File.join(settings.root, "app", "views")
  set :lyrics, File.join(settings.root, "app", "data")
end


# 
# Méthodes accessibles à la fois dans les vues et dans le fichier app.rb
# 
helpers do 
  class String
    def url_encode
      self.gsub ' ', '_'
    end
    def url_decode
      self.gsub '_', ' '
    end
  end

  def readfile(path)
    s = ""
    f = File.open(path, "r")
    f.each_line { |line| s += line }
    f.close
    return s
  end
end


#
# --- Routes de l'application ---
# 


get '/' do 
  # On liste les fichiers présents dans le répertoire settings.lyrics : 
  # chaque fichier correspond à un titre de chanson
  lyrics_path = File.join(settings.lyrics, "*.txt")
  @lyrics = Dir.glob(lyrics_path)

  haml :index
end



get '/song/:title' do
  # On construit le chemin du fichier contenant les paroles de la chanson à
  # partir du titre passé en paramètre
  lyrics_path = File.join(settings.lyrics, "#{params[:title].url_decode}.txt")

  if File.exists?(lyrics_path)
    # Si le fichier existe, on stocke son contenu dans la variable @lyrics
    # et on affiche le template song.haml
    @lyrics = readfile(lyrics_path)
    haml :song
  else 
    # Si le fichier n'existe pas, alors on renvoie une erreur 404
    halt 404
  end
end



not_found do
  haml :err_404
end
