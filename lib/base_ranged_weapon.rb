# 攻撃側プレイヤーの遠隔武器を表現するインターフェース
class BaseRangedWeapon

	# 与えられたRangedWeapon実体の配列について、それぞれ1フレーム分動かした上でシーンから抹消されるべき個体を配列で返す。
	def self.operation(weapons, ground_level)
		removed_weapons = []
		weapons.each do |weapon|
			removed = weapon.move(ground_level)
			removed_weapons << weapon if removed
		end
		return removed_weapons
	end

	# コンストラクタ
	# pos: 爆弾を出現させる初期位置となる座標（Vector3オブジェクト）
	def initialize(pos:)
        raise NotImplementedError.new("#{self.class}##{__method__}が実装されていません")        
	end

	# 爆弾を1フレーム分移動させる。
	# 引数ground_levenは、爆弾が到達できる下限となるY座標値（そこがGround、つまり地表という意味になる）
	def move(ground_level)
        raise NotImplementedError.new("#{self.class}##{__method__}が実装されていません")
	end
end
