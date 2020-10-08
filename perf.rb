require 'sinatra'
require 'digest'

post '/upload' do
	p params
	file = params[:file][:tempfile]
	data = file.read
	md5 = Digest::MD5.hexdigest(data)
	logger.info "size: #{data.size}, md5: #{md5}"
	md5
end
