class Trail < ActiveRecord::Base
	validates_presence_of :longitude_start, :latitude_start, :longitude_end, :latitude_end, :message => 'nie moze byc puste!.'
	validates_numericality_of :longitude_start,  :message => 'nie jest liczba!'
	validates_numericality_of :latitude_start,:message => 'nie jest liczba!'
	validates_numericality_of :longitude_end, :message => 'nie jest liczba!'
	validates_numericality_of :latitude_end, :message => 'nie jest liczba!'
	validates_uniqueness_of :longitude_start, :scope => :latitude_start, :scope => :longitude_end, :scope => :latitude_end, :message => 'Taki zestaw wspolrzednych juz istnieje w bazie!.'
end
