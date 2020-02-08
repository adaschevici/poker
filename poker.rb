class Card
  include Comparable
  attr_accessor :ordinal
  attr_reader :suit, :face

  SUITS = %i(h d c s)
  FACES = %i(2 3 4 5 6 7 8 9 10 j q k a)

  def initialize(str)
    @face, @suit = parse(str)
    @ordinal = FACES.index(@face)
  end

  def <=> (other) #used for sorting
    self.ordinal <=> other.ordinal
  end

  private
  def parse(str)
    face, suit = str.chop.to_sym, str[-1].to_sym
    raise ArgumentError, "invalid card: #{str}" unless FACES.include?(face) && SUITS.include?(suit)
    [face, suit]
  end
end

class Hand
  include Comparable
  attr_reader :cards, :rank

  RANKS = %i(high-card one-pair two-pair three-of-a-kind straight flush
             full-house four-of-a-kind straight-flush)

  def initialize(str_of_cards)
    @cards = str_of_cards.downcase.tr(',', ' ').split.map{|str| Card.new(str)}
    grouped = @cards.group_by(&:face).values
    @face_pattern = grouped.map(&:size).sort
    @rank = categorize
    @rank_num = RANKS.index(@rank)
    @tiebreaker = grouped.map{|ar| [ar.size, ar.first.ordinal]}.sort.reverse
  end

  def <=> (other)
    self.compare_value <=> other.compare_value
  end

  def to_s
    @cards.map(&:to_s).join(" ")
  end

  protected
  def compare_value
    [@rank_num, @tiebreaker]
  end

  private
  def one_suit?
    @cards.map(&:suit).uniq.size == 1
  end

  def consecutive?
    sort.each_cons(2).all? { |c1, c2| c2.ordinal - c1.ordinal == 1 }
  end

  def sort
    @cards.sort
  end

  def categorize
    if consecutive?
      one_suit? ? :'straight-flush' : :straight
    elsif one_suit?
      :flush
    else
      case @face_pattern
        when [1,1,1,1,1] then :'high-card'
        when [1,1,1,2]   then :'one-pair'
        when [1,2,2]     then :'two-pair'
        when [1,1,3]     then :'three-of-a-kind'
        when [2,3]       then :'full-house'
        when [1,4]       then :'four-of-a-kind'
      end
    end
  end
end

hand1 = <<EOS
3D 4D 5D 6D 7D
2H 2D 3C QD KC
EOS

hands = hand1.each_line.map{|line| Hand.new(line)}

p hands[1]::rank > hands[0]::rank
