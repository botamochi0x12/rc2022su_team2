# start_credit
require_relative 'base'

module Directors
	class StartCredit < Base

        def initialize(renderer:, aspect:, camera: nil, next_director_class: Directors::Base.class)
            super

			splash_image = TextBoard.new(
				texture_path: "textures/title_vs_player.png" 
			)  # FIXME
			self.scene.add(splash_image.mesh)

			@_next_director = next_director.new(renderer: renderer, aspect: aspect)
			
			@_countdown = Enumerator.new do |yielder|
				cnt_frames = 60 * 10
				loop do
					yielder << cnt_frames
					# if cnt_frames % 60 == 0
					# 	p "counting down to #{cnt_frames / 60}..."
					# end
					cnt_frames -= 1
				end
			end 

			activate_events
        end

		# @override
		def render_frame
			if @_countdown.next <= 0 
				_transition_scene
			end
		end
        
		private
		def _transition_scene
			# 次のシーンを担当するディレクターのMittsuイベントのアクティベートを行う。
			# ※ シーンを切り替える瞬間に行わないと、後発のディレクターのイベントハンドラで先発のイベントハンドラが
			#    上書きされてしまうため、このタイミングで実行する。
			# @_next_director.activate_events

			# next_directorアクセサを切り替えることで、次のフレームの描画からシーンが切り替わる。
			# ※ このメカニズムはmain.rb側のメインループで実現している点に注意
			self.next_director = @_next_director
		end
    end
end
