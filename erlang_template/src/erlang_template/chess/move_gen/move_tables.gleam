import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/square
import erlang_template/chess/move_gen/magics.{MagicEntry}
import gleam/int
import gleam/list
import glearray
import iv

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

pub const rook_magics_list = [
  MagicEntry(
    mask: 0x000101010101017E,
    magic: 0x5080008011400020,
    shift: 52,
    offset: 0,
  ),
  MagicEntry(
    mask: 0x000202020202027C,
    magic: 0x0140001000402000,
    shift: 53,
    offset: 4096,
  ),
  MagicEntry(
    mask: 0x000404040404047A,
    magic: 0x0280091000200480,
    shift: 53,
    offset: 6144,
  ),
  MagicEntry(
    mask: 0x0008080808080876,
    magic: 0x0700081001002084,
    shift: 53,
    offset: 8192,
  ),
  MagicEntry(
    mask: 0x001010101010106E,
    magic: 0x0300024408010030,
    shift: 53,
    offset: 10_240,
  ),
  MagicEntry(
    mask: 0x002020202020205E,
    magic: 0x510004004E480100,
    shift: 53,
    offset: 12_288,
  ),
  MagicEntry(
    mask: 0x004040404040403E,
    magic: 0x0400044128020090,
    shift: 53,
    offset: 14_336,
  ),
  MagicEntry(
    mask: 0x008080808080807E,
    magic: 0x8080004100012080,
    shift: 52,
    offset: 16_384,
  ),
  MagicEntry(
    mask: 0x0001010101017E00,
    magic: 0x0220800480C00124,
    shift: 53,
    offset: 20_480,
  ),
  MagicEntry(
    mask: 0x0002020202027C00,
    magic: 0x0020401001C02000,
    shift: 54,
    offset: 22_528,
  ),
  MagicEntry(
    mask: 0x0004040404047A00,
    magic: 0x000A002204428050,
    shift: 54,
    offset: 23_552,
  ),
  MagicEntry(
    mask: 0x0008080808087600,
    magic: 0x004E002040100A00,
    shift: 54,
    offset: 24_576,
  ),
  MagicEntry(
    mask: 0x0010101010106E00,
    magic: 0x0102000A00041020,
    shift: 54,
    offset: 25_600,
  ),
  MagicEntry(
    mask: 0x0020202020205E00,
    magic: 0x0A0880040080C200,
    shift: 54,
    offset: 26_624,
  ),
  MagicEntry(
    mask: 0x0040404040403E00,
    magic: 0x0002000600018408,
    shift: 54,
    offset: 27_648,
  ),
  MagicEntry(
    mask: 0x0080808080807E00,
    magic: 0x0025001200518100,
    shift: 53,
    offset: 28_672,
  ),
  MagicEntry(
    mask: 0x00010101017E0100,
    magic: 0x8900328001400080,
    shift: 53,
    offset: 30_720,
  ),
  MagicEntry(
    mask: 0x00020202027C0200,
    magic: 0x0848810020400100,
    shift: 54,
    offset: 32_768,
  ),
  MagicEntry(
    mask: 0x00040404047A0400,
    magic: 0xC001410020010153,
    shift: 54,
    offset: 33_792,
  ),
  MagicEntry(
    mask: 0x0008080808760800,
    magic: 0x4110C90020100101,
    shift: 54,
    offset: 34_816,
  ),
  MagicEntry(
    mask: 0x00101010106E1000,
    magic: 0x00A0808004004800,
    shift: 54,
    offset: 35_840,
  ),
  MagicEntry(
    mask: 0x00202020205E2000,
    magic: 0x401080801C000601,
    shift: 54,
    offset: 36_864,
  ),
  MagicEntry(
    mask: 0x00404040403E4000,
    magic: 0x0100040028104221,
    shift: 54,
    offset: 37_888,
  ),
  MagicEntry(
    mask: 0x00808080807E8000,
    magic: 0x840002000900A054,
    shift: 53,
    offset: 38_912,
  ),
  MagicEntry(
    mask: 0x000101017E010100,
    magic: 0x1000348280004000,
    shift: 53,
    offset: 40_960,
  ),
  MagicEntry(
    mask: 0x000202027C020200,
    magic: 0x001000404000E008,
    shift: 54,
    offset: 43_008,
  ),
  MagicEntry(
    mask: 0x000404047A040400,
    magic: 0x0424410300200035,
    shift: 54,
    offset: 44_032,
  ),
  MagicEntry(
    mask: 0x0008080876080800,
    magic: 0x2008C22200085200,
    shift: 54,
    offset: 45_056,
  ),
  MagicEntry(
    mask: 0x001010106E101000,
    magic: 0x0005304D00080100,
    shift: 54,
    offset: 46_080,
  ),
  MagicEntry(
    mask: 0x002020205E202000,
    magic: 0x000C040080120080,
    shift: 54,
    offset: 47_104,
  ),
  MagicEntry(
    mask: 0x004040403E404000,
    magic: 0x8404058400080210,
    shift: 54,
    offset: 48_128,
  ),
  MagicEntry(
    mask: 0x008080807E808000,
    magic: 0x0001848200010464,
    shift: 53,
    offset: 49_152,
  ),
  MagicEntry(
    mask: 0x0001017E01010100,
    magic: 0x6000204001800280,
    shift: 53,
    offset: 51_200,
  ),
  MagicEntry(
    mask: 0x0002027C02020200,
    magic: 0x2410004003C02010,
    shift: 54,
    offset: 53_248,
  ),
  MagicEntry(
    mask: 0x0004047A04040400,
    magic: 0x0181200A80801000,
    shift: 54,
    offset: 54_272,
  ),
  MagicEntry(
    mask: 0x0008087608080800,
    magic: 0x000C60400A001200,
    shift: 54,
    offset: 55_296,
  ),
  MagicEntry(
    mask: 0x0010106E10101000,
    magic: 0x0B00040180802800,
    shift: 54,
    offset: 56_320,
  ),
  MagicEntry(
    mask: 0x0020205E20202000,
    magic: 0xC00A000280804C00,
    shift: 54,
    offset: 57_344,
  ),
  MagicEntry(
    mask: 0x0040403E40404000,
    magic: 0x4040080504005210,
    shift: 54,
    offset: 58_368,
  ),
  MagicEntry(
    mask: 0x0080807E80808000,
    magic: 0x0000208402000041,
    shift: 53,
    offset: 59_392,
  ),
  MagicEntry(
    mask: 0x00017E0101010100,
    magic: 0xA200400080628000,
    shift: 53,
    offset: 61_440,
  ),
  MagicEntry(
    mask: 0x00027C0202020200,
    magic: 0x0021020240820020,
    shift: 54,
    offset: 63_488,
  ),
  MagicEntry(
    mask: 0x00047A0404040400,
    magic: 0x1020027000848022,
    shift: 54,
    offset: 64_512,
  ),
  MagicEntry(
    mask: 0x0008760808080800,
    magic: 0x0020500018008080,
    shift: 54,
    offset: 65_536,
  ),
  MagicEntry(
    mask: 0x00106E1010101000,
    magic: 0x10000D0008010010,
    shift: 54,
    offset: 66_560,
  ),
  MagicEntry(
    mask: 0x00205E2020202000,
    magic: 0x0100020004008080,
    shift: 54,
    offset: 67_584,
  ),
  MagicEntry(
    mask: 0x00403E4040404000,
    magic: 0x0008020004010100,
    shift: 54,
    offset: 68_608,
  ),
  MagicEntry(
    mask: 0x00807E8080808000,
    magic: 0x12241C0880420003,
    shift: 53,
    offset: 69_632,
  ),
  MagicEntry(
    mask: 0x007E010101010100,
    magic: 0x4000420024810200,
    shift: 53,
    offset: 71_680,
  ),
  MagicEntry(
    mask: 0x007C020202020200,
    magic: 0x0103004000308100,
    shift: 54,
    offset: 73_728,
  ),
  MagicEntry(
    mask: 0x007A040404040400,
    magic: 0x008C200010410300,
    shift: 54,
    offset: 74_752,
  ),
  MagicEntry(
    mask: 0x0076080808080800,
    magic: 0x2410008050A80480,
    shift: 54,
    offset: 75_776,
  ),
  MagicEntry(
    mask: 0x006E101010101000,
    magic: 0x0820880080040080,
    shift: 54,
    offset: 76_800,
  ),
  MagicEntry(
    mask: 0x005E202020202000,
    magic: 0x0044220080040080,
    shift: 54,
    offset: 77_824,
  ),
  MagicEntry(
    mask: 0x003E404040404000,
    magic: 0x2040100805120400,
    shift: 54,
    offset: 78_848,
  ),
  MagicEntry(
    mask: 0x007E808080808000,
    magic: 0x0129000080C20100,
    shift: 53,
    offset: 79_872,
  ),
  MagicEntry(
    mask: 0x7E01010101010100,
    magic: 0x0010402010800101,
    shift: 52,
    offset: 81_920,
  ),
  MagicEntry(
    mask: 0x7C02020202020200,
    magic: 0x0648A01040008101,
    shift: 53,
    offset: 86_016,
  ),
  MagicEntry(
    mask: 0x7A04040404040400,
    magic: 0x0006084102A00033,
    shift: 53,
    offset: 88_064,
  ),
  MagicEntry(
    mask: 0x7608080808080800,
    magic: 0x0002000870C06006,
    shift: 53,
    offset: 90_112,
  ),
  MagicEntry(
    mask: 0x6E10101010101000,
    magic: 0x0082008820100402,
    shift: 53,
    offset: 92_160,
  ),
  MagicEntry(
    mask: 0x5E20202020202000,
    magic: 0x0012008410050806,
    shift: 53,
    offset: 94_208,
  ),
  MagicEntry(
    mask: 0x3E40404040404000,
    magic: 0x2009408802100144,
    shift: 53,
    offset: 96_256,
  ),
  MagicEntry(
    mask: 0x7E80808080808000,
    magic: 0x821080440020810A,
    shift: 52,
    offset: 98_304,
  ),
]

pub const rook_table_size = 102_400

pub const bishop_magics_list = [
  MagicEntry(
    mask: 0x0040201008040200,
    magic: 0x2020420401002200,
    shift: 58,
    offset: 0,
  ),
  MagicEntry(
    mask: 0x0000402010080400,
    magic: 0x05210A020A002118,
    shift: 59,
    offset: 64,
  ),
  MagicEntry(
    mask: 0x0000004020100A00,
    magic: 0x1110040454C00484,
    shift: 59,
    offset: 96,
  ),
  MagicEntry(
    mask: 0x0000000040221400,
    magic: 0x1008095104080000,
    shift: 59,
    offset: 128,
  ),
  MagicEntry(
    mask: 0x0000000002442800,
    magic: 0xC409104004000000,
    shift: 59,
    offset: 160,
  ),
  MagicEntry(
    mask: 0x0000000204085000,
    magic: 0x0002901048080200,
    shift: 59,
    offset: 192,
  ),
  MagicEntry(
    mask: 0x0000020408102000,
    magic: 0x0044040402084301,
    shift: 59,
    offset: 224,
  ),
  MagicEntry(
    mask: 0x0002040810204000,
    magic: 0x2002030188040200,
    shift: 58,
    offset: 256,
  ),
  MagicEntry(
    mask: 0x0020100804020000,
    magic: 0x0000C8084808004A,
    shift: 59,
    offset: 320,
  ),
  MagicEntry(
    mask: 0x0040201008040000,
    magic: 0x1040040808010028,
    shift: 59,
    offset: 352,
  ),
  MagicEntry(
    mask: 0x00004020100A0000,
    magic: 0x40040C0114090051,
    shift: 59,
    offset: 384,
  ),
  MagicEntry(
    mask: 0x0000004022140000,
    magic: 0x40004820802004C4,
    shift: 59,
    offset: 416,
  ),
  MagicEntry(
    mask: 0x0000000244280000,
    magic: 0x0010042420260012,
    shift: 59,
    offset: 448,
  ),
  MagicEntry(
    mask: 0x0000020408500000,
    magic: 0x10024202300C010A,
    shift: 59,
    offset: 480,
  ),
  MagicEntry(
    mask: 0x0002040810200000,
    magic: 0x000054013D101000,
    shift: 59,
    offset: 512,
  ),
  MagicEntry(
    mask: 0x0004081020400000,
    magic: 0x0100020482188A0A,
    shift: 59,
    offset: 544,
  ),
  MagicEntry(
    mask: 0x0010080402000200,
    magic: 0x0120090421020200,
    shift: 59,
    offset: 576,
  ),
  MagicEntry(
    mask: 0x0020100804000400,
    magic: 0x1022204444040C00,
    shift: 59,
    offset: 608,
  ),
  MagicEntry(
    mask: 0x004020100A000A00,
    magic: 0x0008000400440288,
    shift: 57,
    offset: 640,
  ),
  MagicEntry(
    mask: 0x0000402214001400,
    magic: 0x0008060082004040,
    shift: 57,
    offset: 768,
  ),
  MagicEntry(
    mask: 0x0000024428002800,
    magic: 0x0044040081A00800,
    shift: 57,
    offset: 896,
  ),
  MagicEntry(
    mask: 0x0002040850005000,
    magic: 0x021200014308A010,
    shift: 57,
    offset: 1024,
  ),
  MagicEntry(
    mask: 0x0004081020002000,
    magic: 0x8604040080880809,
    shift: 59,
    offset: 1152,
  ),
  MagicEntry(
    mask: 0x0008102040004000,
    magic: 0x0000802D46009049,
    shift: 59,
    offset: 1184,
  ),
  MagicEntry(
    mask: 0x0008040200020400,
    magic: 0x00500E8040080604,
    shift: 59,
    offset: 1216,
  ),
  MagicEntry(
    mask: 0x0010080400040800,
    magic: 0x0024030030100320,
    shift: 59,
    offset: 1248,
  ),
  MagicEntry(
    mask: 0x0020100A000A1000,
    magic: 0x2004100002002440,
    shift: 57,
    offset: 1280,
  ),
  MagicEntry(
    mask: 0x0040221400142200,
    magic: 0x02090C0008440080,
    shift: 55,
    offset: 1408,
  ),
  MagicEntry(
    mask: 0x0002442800284400,
    magic: 0x0205010000104000,
    shift: 55,
    offset: 1920,
  ),
  MagicEntry(
    mask: 0x0004085000500800,
    magic: 0x0410820405004A00,
    shift: 57,
    offset: 2432,
  ),
  MagicEntry(
    mask: 0x0008102000201000,
    magic: 0x8004140261012100,
    shift: 59,
    offset: 2560,
  ),
  MagicEntry(
    mask: 0x0010204000402000,
    magic: 0x0A00460000820100,
    shift: 59,
    offset: 2592,
  ),
  MagicEntry(
    mask: 0x0004020002040800,
    magic: 0x201004A40A101044,
    shift: 59,
    offset: 2624,
  ),
  MagicEntry(
    mask: 0x0008040004081000,
    magic: 0x840C024220208440,
    shift: 59,
    offset: 2656,
  ),
  MagicEntry(
    mask: 0x00100A000A102000,
    magic: 0x000C002E00240401,
    shift: 57,
    offset: 2688,
  ),
  MagicEntry(
    mask: 0x0022140014224000,
    magic: 0x2220A00800010106,
    shift: 55,
    offset: 2816,
  ),
  MagicEntry(
    mask: 0x0044280028440200,
    magic: 0x88C0080820060020,
    shift: 55,
    offset: 3328,
  ),
  MagicEntry(
    mask: 0x0008500050080400,
    magic: 0x0818030B00A81041,
    shift: 57,
    offset: 3840,
  ),
  MagicEntry(
    mask: 0x0010200020100800,
    magic: 0xC091280200110900,
    shift: 59,
    offset: 3968,
  ),
  MagicEntry(
    mask: 0x0020400040201000,
    magic: 0x08A8114088804200,
    shift: 59,
    offset: 4000,
  ),
  MagicEntry(
    mask: 0x0002000204081000,
    magic: 0x228929109000C001,
    shift: 59,
    offset: 4032,
  ),
  MagicEntry(
    mask: 0x0004000408102000,
    magic: 0x1230480209205000,
    shift: 59,
    offset: 4064,
  ),
  MagicEntry(
    mask: 0x000A000A10204000,
    magic: 0x0A43040202000102,
    shift: 57,
    offset: 4096,
  ),
  MagicEntry(
    mask: 0x0014001422400000,
    magic: 0x1011284010444600,
    shift: 57,
    offset: 4224,
  ),
  MagicEntry(
    mask: 0x0028002844020000,
    magic: 0x0003041008864400,
    shift: 57,
    offset: 4352,
  ),
  MagicEntry(
    mask: 0x0050005008040200,
    magic: 0x0115010901000200,
    shift: 57,
    offset: 4480,
  ),
  MagicEntry(
    mask: 0x0020002010080400,
    magic: 0x01200402C0840201,
    shift: 59,
    offset: 4608,
  ),
  MagicEntry(
    mask: 0x0040004020100800,
    magic: 0x001A009400822110,
    shift: 59,
    offset: 4640,
  ),
  MagicEntry(
    mask: 0x0000020408102000,
    magic: 0x2002111128410000,
    shift: 59,
    offset: 4672,
  ),
  MagicEntry(
    mask: 0x0000040810204000,
    magic: 0x8420410288203000,
    shift: 59,
    offset: 4704,
  ),
  MagicEntry(
    mask: 0x00000A1020400000,
    magic: 0x0041210402090081,
    shift: 59,
    offset: 4736,
  ),
  MagicEntry(
    mask: 0x0000142240000000,
    magic: 0x8220002442120842,
    shift: 59,
    offset: 4768,
  ),
  MagicEntry(
    mask: 0x0000284402000000,
    magic: 0x0140004010450000,
    shift: 59,
    offset: 4800,
  ),
  MagicEntry(
    mask: 0x0000500804020000,
    magic: 0xC0408860086488A0,
    shift: 59,
    offset: 4832,
  ),
  MagicEntry(
    mask: 0x0000201008040200,
    magic: 0x0090203E00820002,
    shift: 59,
    offset: 4864,
  ),
  MagicEntry(
    mask: 0x0000402010080400,
    magic: 0x0820020083090024,
    shift: 59,
    offset: 4896,
  ),
  MagicEntry(
    mask: 0x0002040810204000,
    magic: 0x1040440210900C05,
    shift: 58,
    offset: 4928,
  ),
  MagicEntry(
    mask: 0x0004081020400000,
    magic: 0x0818182101082000,
    shift: 59,
    offset: 4992,
  ),
  MagicEntry(
    mask: 0x000A102040000000,
    magic: 0x0200800080D80800,
    shift: 59,
    offset: 5024,
  ),
  MagicEntry(
    mask: 0x0014224000000000,
    magic: 0x32A9220510209801,
    shift: 59,
    offset: 5056,
  ),
  MagicEntry(
    mask: 0x0028440200000000,
    magic: 0x0000901010820200,
    shift: 59,
    offset: 5088,
  ),
  MagicEntry(
    mask: 0x0050080402000000,
    magic: 0x0000014064080180,
    shift: 59,
    offset: 5120,
  ),
  MagicEntry(
    mask: 0x0020100804020000,
    magic: 0xA001204204080186,
    shift: 59,
    offset: 5152,
  ),
  MagicEntry(
    mask: 0x0040201008040200,
    magic: 0xC04010040258C048,
    shift: 58,
    offset: 5184,
  ),
]

pub const bishop_table_size = 5248

pub type MoveTables {
  MoveTables(
    white_pawn_table: glearray.Array(Int),
    black_pawn_table: glearray.Array(Int),
    white_pawn_capture_table: glearray.Array(Int),
    black_pawn_capture_table: glearray.Array(Int),
    knight_table: glearray.Array(Int),
    king_table: glearray.Array(Int),
    rook_magics: glearray.Array(magics.MagicEntry),
    rook_moves: glearray.Array(glearray.Array(Int)),
    bishop_magics: glearray.Array(magics.MagicEntry),
    bishop_moves: glearray.Array(glearray.Array(Int)),
  )
}

const rook_move_shifts = [-1, 1, -8, 8]

const bishop_move_shifts = [-7, 7, -9, 9]

pub fn new() -> MoveTables {
  let rook_magics = glearray.from_list(rook_magics_list)
  let bishop_magics = glearray.from_list(bishop_magics_list)

  let rook_moves =
    generate_magic_table(rook_table_size, rook_move_shifts, rook_magics)
    |> list.map(glearray.from_list)
    |> glearray.from_list
  let bishop_moves =
    generate_magic_table(bishop_table_size, bishop_move_shifts, bishop_magics)
    |> list.map(glearray.from_list)
    |> glearray.from_list

  MoveTables(
    white_pawn_table: glearray.from_list(white_pawn_moves),
    black_pawn_table: glearray.from_list(black_pawn_moves),
    white_pawn_capture_table: glearray.from_list(white_pawn_captures),
    black_pawn_capture_table: glearray.from_list(black_pawn_captures),
    knight_table: glearray.from_list(knight_moves),
    king_table: glearray.from_list(king_moves),
    rook_magics: rook_magics,
    rook_moves: rook_moves,
    bishop_magics: bishop_magics,
    bishop_moves: bishop_moves,
  )
}

fn generate_magic_table(
  length: Int,
  shifts: List(Int),
  magics: glearray.Array(magics.MagicEntry),
) -> List(List(Int)) {
  use square <- list.map(square.all_squares)
  let index = square.index(square)
  let assert Ok(magic_entry) = magics |> glearray.get(index)

  magic_entry.mask
  |> bitboard.map_subsets(fn(blockers) {
    let moves = sliding_targets(square, blockers, shifts)
    let target_magic_index = magics.magic_index(magic_entry, blockers)
    #(moves, target_magic_index)
  })
  |> list.fold(iv.repeat(0, length), fn(a, b) {
    let assert Ok(res) = a |> iv.set(at: b.1, to: b.0)
    res
  })
  |> iv.to_list
}

pub fn rook_targets(
  square: square.Square,
  blockers: Int,
  move_tables: MoveTables,
) -> Int {
  let i = square |> square.index
  let assert Ok(magic) = move_tables.rook_magics |> glearray.get(i)
  let assert Ok(moves) = move_tables.rook_moves |> glearray.get(i)
  let assert Ok(targets) =
    moves |> glearray.get(magics.magic_index(magic, blockers))
  targets
}

pub fn bishop_targets(
  square: square.Square,
  blockers: Int,
  move_tables: MoveTables,
) -> Int {
  let i = square |> square.index
  let assert Ok(magic) = move_tables.bishop_magics |> glearray.get(i)
  let assert Ok(moves) = move_tables.bishop_moves |> glearray.get(i)
  let assert Ok(targets) =
    moves |> glearray.get(magics.magic_index(magic, blockers))
  targets
}

pub fn sliding_targets(square: square.Square, blockers: Int, shifts: List(Int)) {
  let index = square.index(square)

  shifts
  |> list.map(fn(shift) { slide_recursive(index, shift, blockers) })
  |> list.fold(0, int.bitwise_or)
  |> remove_edges(index)
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

fn remove_edges(mask: Int, start: Int) {
  let rank = square.rank(start)
  let file = square.file(start)

  mask
  |> int.bitwise_and(
    int.bitwise_not(case rank {
      // apply only 8th rank filter
      0 -> 0xff00000000000000
      // apply only 1st rank filter
      7 -> 0x00000000000000ff
      // apply both
      _ -> int.bitwise_or(0x00000000000000ff, 0xff00000000000000)
    }),
  )
  |> int.bitwise_and(
    int.bitwise_not(case file {
      // apply only H file filter
      0 -> 0x8080808080808080
      // apply only A file filter
      7 -> 0x0101010101010101
      // apply both
      _ -> int.bitwise_or(0x0101010101010101, 0x8080808080808080)
    }),
  )
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
  let assert Ok(neighbours) = move_tables.king_table |> glearray.get(i)
  mask |> int.bitwise_and(neighbours)
}
