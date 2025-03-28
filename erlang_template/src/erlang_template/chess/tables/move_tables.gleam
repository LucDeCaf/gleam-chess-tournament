import erlang_template/chess/board/color
import erlang_template/chess/board/square
import erlang_template/chess/tables
import gleam/int
import gleam/list
import glearray

const white_pawn_moves = [
  0, 0, 0, 0, 0, 0, 0, 0, 65_536, 131_072, 262_144, 524_288, 1_048_576,
  2_097_152, 4_194_304, 8_388_608, 16_777_216, 33_554_432, 67_108_864,
  134_217_728, 268_435_456, 536_870_912, 1_073_741_824, 2_147_483_648,
  4_294_967_296, 8_589_934_592, 17_179_869_184, 34_359_738_368, 68_719_476_736,
  137_438_953_472, 274_877_906_944, 549_755_813_888, 1_099_511_627_776,
  2_199_023_255_552, 4_398_046_511_104, 8_796_093_022_208, 17_592_186_044_416,
  35_184_372_088_832, 70_368_744_177_664, 140_737_488_355_328,
  281_474_976_710_656, 562_949_953_421_312, 1_125_899_906_842_624,
  2_251_799_813_685_248, 4_503_599_627_370_496, 9_007_199_254_740_992,
  18_014_398_509_481_984, 36_028_797_018_963_968, 72_057_594_037_927_936,
  144_115_188_075_855_872, 288_230_376_151_711_744, 576_460_752_303_423_488,
  1_152_921_504_606_846_976, 2_305_843_009_213_693_952,
  4_611_686_018_427_387_904, 9_223_372_036_854_775_808, 0, 0, 0, 0, 0, 0, 0, 0,
]

const black_pawn_moves = [
  0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048,
  4096, 8192, 16_384, 32_768, 65_536, 131_072, 262_144, 524_288, 1_048_576,
  2_097_152, 4_194_304, 8_388_608, 16_777_216, 33_554_432, 67_108_864,
  134_217_728, 268_435_456, 536_870_912, 1_073_741_824, 2_147_483_648,
  4_294_967_296, 8_589_934_592, 17_179_869_184, 34_359_738_368, 68_719_476_736,
  137_438_953_472, 274_877_906_944, 549_755_813_888, 1_103_806_595_072,
  2_207_613_190_144, 4_415_226_380_288, 8_830_452_760_576, 17_660_905_521_152,
  35_321_811_042_304, 70_643_622_084_608, 141_287_244_169_216, 0, 0, 0, 0, 0, 0,
  0, 0,
]

const white_pawn_captures = [
  512, 1280, 2560, 5120, 10_240, 20_480, 40_960, 16_384, 131_072, 327_680,
  655_360, 1_310_720, 2_621_440, 5_242_880, 10_485_760, 4_194_304, 33_554_432,
  83_886_080, 167_772_160, 335_544_320, 671_088_640, 1_342_177_280,
  2_684_354_560, 1_073_741_824, 8_589_934_592, 21_474_836_480, 42_949_672_960,
  85_899_345_920, 171_798_691_840, 343_597_383_680, 687_194_767_360,
  274_877_906_944, 2_199_023_255_552, 5_497_558_138_880, 10_995_116_277_760,
  21_990_232_555_520, 43_980_465_111_040, 87_960_930_222_080,
  175_921_860_444_160, 70_368_744_177_664, 562_949_953_421_312,
  1_407_374_883_553_280, 2_814_749_767_106_560, 5_629_499_534_213_120,
  11_258_999_068_426_240, 22_517_998_136_852_480, 45_035_996_273_704_960,
  18_014_398_509_481_984, 144_115_188_075_855_872, 360_287_970_189_639_680,
  720_575_940_379_279_360, 1_441_151_880_758_558_720, 2_882_303_761_517_117_440,
  5_764_607_523_034_234_880, 11_529_215_046_068_469_760,
  4_611_686_018_427_387_904, 0, 0, 0, 0, 0, 0, 0, 0,
]

const black_pawn_captures = [
  0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 10, 20, 40, 80, 160, 64, 512, 1280, 2560, 5120,
  10_240, 20_480, 40_960, 16_384, 131_072, 327_680, 655_360, 1_310_720,
  2_621_440, 5_242_880, 10_485_760, 4_194_304, 33_554_432, 83_886_080,
  167_772_160, 335_544_320, 671_088_640, 1_342_177_280, 2_684_354_560,
  1_073_741_824, 8_589_934_592, 21_474_836_480, 42_949_672_960, 85_899_345_920,
  171_798_691_840, 343_597_383_680, 687_194_767_360, 274_877_906_944,
  2_199_023_255_552, 5_497_558_138_880, 10_995_116_277_760, 21_990_232_555_520,
  43_980_465_111_040, 87_960_930_222_080, 175_921_860_444_160,
  70_368_744_177_664, 562_949_953_421_312, 1_407_374_883_553_280,
  2_814_749_767_106_560, 5_629_499_534_213_120, 11_258_999_068_426_240,
  22_517_998_136_852_480, 45_035_996_273_704_960, 18_014_398_509_481_984,
]

const knight_moves = [
  132_096, 329_728, 659_712, 1_319_424, 2_638_848, 5_277_696, 10_489_856,
  4_202_496, 33_816_580, 84_410_376, 168_886_289, 337_772_578, 675_545_156,
  1_351_090_312, 2_685_403_152, 1_075_839_008, 8_657_044_482, 21_609_056_261,
  43_234_889_994, 86_469_779_988, 172_939_559_976, 345_879_119_952,
  687_463_207_072, 275_414_786_112, 2_216_203_387_392, 5_531_918_402_816,
  11_068_131_838_464, 22_136_263_676_928, 44_272_527_353_856, 88_545_054_707_712,
  175_990_581_010_432, 70_506_185_244_672, 567_348_067_172_352,
  1_416_171_111_120_896, 2_833_441_750_646_784, 5_666_883_501_293_568,
  11_333_767_002_587_136, 22_667_534_005_174_272, 45_053_588_738_670_592,
  18_049_583_422_636_032, 145_241_105_196_122_112, 362_539_804_446_949_376,
  725_361_088_165_576_704, 1_450_722_176_331_153_408, 2_901_444_352_662_306_816,
  5_802_888_705_324_613_632, 11_533_718_717_099_671_552,
  4_620_693_356_194_824_192, 288_234_782_788_157_440, 576_469_569_871_282_176,
  1_224_997_833_292_120_064, 2_449_995_666_584_240_128,
  4_899_991_333_168_480_256, 9_799_982_666_336_960_512,
  1_152_939_783_987_658_752, 2_305_878_468_463_689_728, 1_128_098_930_098_176,
  2_257_297_371_824_128, 4_796_069_720_358_912, 9_592_139_440_717_824,
  19_184_278_881_435_648, 38_368_557_762_871_296, 4_679_521_487_814_656,
  9_077_567_998_918_656,
]

const king_moves = [
  770, 1797, 3594, 7188, 14_376, 28_752, 57_504, 49_216, 197_123, 460_039,
  920_078, 1_840_156, 3_680_312, 7_360_624, 14_721_248, 12_599_488, 50_463_488,
  117_769_984, 235_539_968, 471_079_936, 942_159_872, 1_884_319_744,
  3_768_639_488, 3_225_468_928, 12_918_652_928, 30_149_115_904, 60_298_231_808,
  120_596_463_616, 241_192_927_232, 482_385_854_464, 964_771_708_928,
  825_720_045_568, 3_307_175_149_568, 7_718_173_671_424, 15_436_347_342_848,
  30_872_694_685_696, 61_745_389_371_392, 123_490_778_742_784,
  246_981_557_485_568, 211_384_331_665_408, 846_636_838_289_408,
  1_975_852_459_884_544, 3_951_704_919_769_088, 7_903_409_839_538_176,
  15_806_819_679_076_352, 31_613_639_358_152_704, 63_227_278_716_305_408,
  54_114_388_906_344_448, 216_739_030_602_088_448, 505_818_229_730_443_264,
  1_011_636_459_460_886_528, 2_023_272_918_921_773_056,
  4_046_545_837_843_546_112, 8_093_091_675_687_092_224,
  16_186_183_351_374_184_448, 13_853_283_560_024_178_688,
  144_959_613_005_987_840, 362_258_295_026_614_272, 724_516_590_053_228_544,
  1_449_033_180_106_457_088, 2_898_066_360_212_914_176,
  5_796_132_720_425_828_352, 11_592_265_440_851_656_704,
  4_665_729_213_955_833_856,
]

pub type MoveTables {
  MoveTables(
    white_pawn_targets: tables.TableGetter,
    black_pawn_targets: tables.TableGetter,
    white_pawn_capture_targets: tables.TableGetter,
    black_pawn_capture_targets: tables.TableGetter,
    knight_targets: tables.TableGetter,
    king_targets: tables.TableGetter,
  )
}

pub const rook_move_shifts = [-1, 1, -8, 8]

pub const bishop_move_shifts = [-7, 7, -9, 9]

pub const queen_move_shifts = [-1, 1, -8, 8, -7, 7, -9, 9]

pub fn new() -> MoveTables {
  let white_pawn_table = glearray.from_list(white_pawn_moves)
  let black_pawn_table = glearray.from_list(black_pawn_moves)
  let white_pawn_capture_table = glearray.from_list(white_pawn_captures)
  let black_pawn_capture_table = glearray.from_list(black_pawn_captures)
  let knight_table = glearray.from_list(knight_moves)
  let king_table = glearray.from_list(king_moves)

  let white_pawn_getter = tables.make_table_getter(white_pawn_table)
  let black_pawn_getter = tables.make_table_getter(black_pawn_table)
  let white_pawn_capture_getter =
    tables.make_table_getter(white_pawn_capture_table)
  let black_pawn_capture_getter =
    tables.make_table_getter(black_pawn_capture_table)
  let knight_getter = tables.make_table_getter(knight_table)
  let king_getter = tables.make_table_getter(king_table)

  MoveTables(
    white_pawn_targets: white_pawn_getter,
    black_pawn_targets: black_pawn_getter,
    white_pawn_capture_targets: white_pawn_capture_getter,
    black_pawn_capture_targets: black_pawn_capture_getter,
    knight_targets: knight_getter,
    king_targets: king_getter,
  )
}

pub fn sliding_targets(square: square.Square, blockers: Int, shifts: List(Int)) {
  let index = square.index(square)

  shifts
  |> list.map(fn(shift) { slide_recursive(index, shift, blockers) })
  |> list.fold(0, int.bitwise_or)
}

fn slide_recursive(index: Int, shift: Int, blockers: Int) {
  slide_recursive_inner(index, shift, blockers, 0)
}

fn slide_recursive_inner(index: Int, shift: Int, blockers: Int, accum: Int) {
  let next_index = index + shift
  let current_rank = square.rank(index)
  let current_file = square.file(index)
  let next_rank = square.rank(next_index)
  let next_file = square.file(next_index)
  let rank_diff = int.absolute_value(current_rank - next_rank)
  let file_diff = int.absolute_value(current_file - next_file)

  case next_index < 0 || next_index > 63 || rank_diff > 1 || file_diff > 1 {
    // Base case
    True -> accum
    // Body
    False -> {
      let next_mask = 1 |> int.bitwise_shift_left(next_index)
      let masks_so_far = next_mask |> int.bitwise_or(accum)
      case int.bitwise_and(next_mask, blockers) > 0 {
        // Collision
        True -> masks_so_far
        // No collision - keep going
        False ->
          slide_recursive_inner(next_index, shift, blockers, masks_so_far)
      }
    }
  }
}

pub fn en_passant_source_masks(
  target: square.Square,
  attacking_color: color.Color,
  move_tables: MoveTables,
) {
  let i = square.index(target)
  let mask = case attacking_color {
    color.White ->
      int.bitwise_or(
        1 |> int.bitwise_shift_left(i - 7),
        1 |> int.bitwise_shift_left(i - 9),
      )
    color.Black ->
      int.bitwise_or(
        1 |> int.bitwise_shift_left(i + 7),
        1 |> int.bitwise_shift_left(i + 9),
      )
  }

  // Prevent wrapping by AND'ing with the square's king mask
  let neighbours = move_tables.king_targets(target)
  mask |> int.bitwise_and(neighbours)
}
