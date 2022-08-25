# bulletin_boardmv 
require_relative 'base'
require_relative 'game'  # FIXME

# TODO: Show lines of playernames that servived this game.
# TODO: Transition to the Game Over scence.
module Directors
	class BulletinBoard < Base
		attr_accessor :score

        def initialize(renderer:, aspect:)
            super
			
			# Create a score board UI
			score_board = TextBoard.new(texture_path: "textures/score.png", value: Directors::Game::VS_COM_MODE)
			self.scene.add(score_board.mesh)
			
			@_next_director = nil 
			# Directors::GameOver.new(renderer: renderer, aspect: aspect)

			@cnt_frame = 0
			puts "#{self} has been initialized"
        end

		# @override
		# 1フレーム分のゲーム進行処理
		def render_frame
			@cnt_frame += 1
			escape_key_pressed = false
			puts "#{@cnt_frame} has passsed..." if @cnt_frame % 60 == 0
			if escape_key_pressed 
				puts "escape key has been pressed, then transition to the game over."
				_transition_to_game_over
			end
		end

		private

		def _transition_to_game_over
			# 次のシーンを担当するディレクターのMittsuイベントのアクティベートを行う。
			# ※ シーンを切り替える瞬間に行わないと、後発のディレクターのイベントハンドラで先発のイベントハンドラが
			#    上書きされてしまうため、このタイミングで実行する。
			@_next_director.activate_events

			# next_directorアクセサを切り替えることで、次のフレームの描画からシーンが切り替わる。
			# ※ このメカニズムはmain.rb側のメインループで実現している点に注意
			self.next_director = @_next_director
		end
    end
end
