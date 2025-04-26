// Token enum and related functionality
enum Token {
  SOL('So11111111111111111111111111111111111111112', 9),
  ETH('7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs', 8),
  WBTC('3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh', 8);

  final String mintAddress;
  final int decimals;
  const Token(this.mintAddress, this.decimals);
}

enum TradeType {
  long,
  short,
} 