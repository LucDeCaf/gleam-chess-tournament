import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/square
import erlang_template/chess/tables
import erlang_template/chess/tables/magics
import gleam/int
import gleam/list
import gleam/order
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

const rook_magics = [
  magics.MagicEntry(
    mask: 282_578_800_148_862,
    magic: 9_516_108_223_737_233_408,
    shift: 52,
  ),
  magics.MagicEntry(
    mask: 565_157_600_297_596,
    magic: 434_633_652_836_499_457,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 1_130_315_200_595_066,
    magic: 9_368_613_202_148_982_784,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 2_260_630_401_190_006,
    magic: 9_511_637_614_562_934_785,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 4_521_260_802_379_886,
    magic: 864_695_664_544_714_752,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 9_042_521_604_759_646,
    magic: 288_234_843_018_436_608,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 18_085_043_209_519_166,
    magic: 288_248_140_706_907_136,
    shift: 53,
  ),
  magics.MagicEntry(mask: 126, magic: 9_224_533_139_389_554_692, shift: 52),
  magics.MagicEntry(
    mask: 282_578_800_180_736,
    magic: 9_260_526_942_153_670_656,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 565_157_600_328_704,
    magic: 5_630_053_589_450_753,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 1_130_315_200_625_152,
    magic: 13_686_996_157_464_576,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_260_630_401_218_048,
    magic: 10_133_378_469_756_928,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 4_521_260_802_403_840,
    magic: 1_125_969_700_327_424,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 9_042_521_604_775_424,
    magic: 285_873_090_461_696,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 18_085_043_209_518_592,
    magic: 562_958_543_684_608,
    shift: 54,
  ),
  magics.MagicEntry(mask: 32_256, magic: 9_909_045_629_888_300_040, shift: 53),
  magics.MagicEntry(
    mask: 282_578_808_340_736,
    magic: 1_152_939_234_273_787_904,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 565_157_608_292_864,
    magic: 2_306_414_824_050_982_912,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 1_130_315_208_328_192,
    magic: 10_682_543_401_634_758_657,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_260_630_408_398_848,
    magic: 107_752_427_487_232,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 4_521_260_808_540_160,
    magic: 21_990_405_595_136,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 9_042_521_608_822_784,
    magic: 72_094_978_105_410_560,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 18_085_043_209_388_032,
    magic: 9_953_097_015_704_044_544,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 8_257_536,
    magic: 1_406_834_078_538_530_817,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 282_580_897_300_736,
    magic: 576_463_559_073_202_176,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 565_159_647_117_824,
    magic: 144_117_593_526_239_296,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 1_130_317_180_306_432,
    magic: 4_611_686_087_314_898_944,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_260_632_246_683_648,
    magic: 6_772_993_775_124_480,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 4_521_262_379_438_080,
    magic: 72_057_748_657_276_176,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 9_042_522_644_946_944,
    magic: 17_180_004_353,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 18_085_043_175_964_672,
    magic: 4_974_225_792_735_248_384,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_113_929_216,
    magic: 13_842_517_143_243_195_457,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 283_115_671_060_736,
    magic: 9_007_476_355_629_856,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 565_681_586_307_584,
    magic: 141_012_376_879_105,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 1_130_822_006_735_872,
    magic: 2_254_668_860_260_352,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_261_102_847_592_448,
    magic: 9_368_939_121_360_896,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 4_521_664_529_305_600,
    magic: 2_882_312_630_960_136_192,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 9_042_787_892_731_904,
    magic: 49_561_586_183_972_864,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 18_085_034_619_584_512,
    magic: 2_314_850_227_841_990_656,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 541_165_879_296,
    magic: 1_126_038_587_310_088,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 420_017_753_620_736,
    magic: 22_590_568_087_683_073,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 699_298_018_886_144,
    magic: 1_196_277_778_186_240,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 1_260_057_572_672_512,
    magic: 72_066_540_598_198_280,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 2_381_576_680_245_248,
    magic: 1_152_922_196_097_171_456,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 4_624_614_895_390_720,
    magic: 81_064_827_803_705_346,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 9_110_691_325_681_664,
    magic: 4_647_714_884_703_223_812,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 18_082_844_186_263_552,
    magic: 182_395_854_164_934_656,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 138_538_465_099_776,
    magic: 9_224_498_005_483_201_040,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 35_466_950_888_980_736,
    magic: 8_070_453_359_443_778_560,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 34_905_104_758_997_504,
    magic: 9_295_431_280_731_685_376,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 34_344_362_452_452_352,
    magic: 4_629_700_571_826_225_280,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 33_222_877_839_362_048,
    magic: 2_305_843_284_360_044_801,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 30_979_908_613_181_440,
    magic: 9_223_374_407_962_198_080,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 26_493_970_160_820_224,
    magic: 580_964_386_559_108_096,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 17_522_093_256_097_792,
    magic: 18_014_673_420_953_920,
    shift: 54,
  ),
  magics.MagicEntry(
    mask: 35_465_847_065_542_656,
    magic: 274_953_797_763,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 9_079_539_427_579_068_672,
    magic: 9_367_490_534_882_410_769,
    shift: 52,
  ),
  magics.MagicEntry(
    mask: 8_935_706_818_303_361_536,
    magic: 4_611_686_714_262_437_908,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 8_792_156_787_827_803_136,
    magic: 13_835_058_606_133_741_604,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 8_505_056_726_876_686_336,
    magic: 51_606_814_740,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 7_930_856_604_974_452_736,
    magic: 4_503_720_021_202_436,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 6_782_456_361_169_985_536,
    magic: 1_161_118_672_293_956,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 4_485_655_873_561_051_136,
    magic: 45_601_352_080_490_636,
    shift: 53,
  ),
  magics.MagicEntry(
    mask: 9_079_256_848_778_919_936,
    magic: 75_998_243_720_791_298,
    shift: 52,
  ),
]

const bishop_magics = [
  magics.MagicEntry(
    mask: 18_049_651_735_527_936,
    magic: 9_571_253_031_796_736,
    shift: 58,
  ),
  magics.MagicEntry(
    mask: 70_506_452_091_904,
    magic: 297_246_380_093_620_480,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 275_415_828_992,
    magic: 31_526_298_246_447_232,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 1_075_975_168,
    magic: 1_157_710_977_327_169_552,
    shift: 59,
  ),
  magics.MagicEntry(mask: 38_021_120, magic: 18_867_619_532_774_720, shift: 59),
  magics.MagicEntry(mask: 8_657_588_224, magic: 286_010_462_175_232, shift: 59),
  magics.MagicEntry(
    mask: 2_216_338_399_232,
    magic: 4_611_840_002_131_757_056,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 567_382_630_219_776,
    magic: 36_594_397_034_971_170,
    shift: 58,
  ),
  magics.MagicEntry(
    mask: 9_024_825_867_763_712,
    magic: 1_731_706_693_497_192_458,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 18_049_651_735_527_424,
    magic: 2_216_605_908_992,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 70_506_452_221_952,
    magic: 193_516_470_797_312,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 275_449_643_008,
    magic: 9_224_502_420_716_421_120,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 9_733_406_720,
    magic: 1_749_808_573_761_718_274,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_216_342_585_344,
    magic: 73_469_444_344_512_520,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 567_382_630_203_392,
    magic: 2_271_593_481_109_664,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 1_134_765_260_406_784,
    magic: 3_377_841_522_611_332,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 4_512_412_933_816_832,
    magic: 60_180_922_480,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 9_024_825_867_633_664,
    magic: 216_175_194_007_537_728,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 18_049_651_768_822_272,
    magic: 15_001_491_459_423_639_584,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 70_515_108_615_168,
    magic: 10_376_298_497_890_189_440,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 2_491_752_130_560,
    magic: 145_241_089_123_592_360,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 567_383_701_868_544,
    magic: 4_611_686_294_397_911_145,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 1_134_765_256_220_672,
    magic: 49_685_273_313_280,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_269_530_512_441_344,
    magic: 297_246_380_526_731_264,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_256_206_450_263_040,
    magic: 4_899_951_597_205_061_637,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 4_512_412_900_526_080,
    magic: 4_611_688_217_518_178_336,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 9_024_834_391_117_824,
    magic: 144_695_730_224_824_324,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 18_051_867_805_491_712,
    magic: 3_378_250_017_554_432,
    shift: 55,
  ),
  magics.MagicEntry(
    mask: 637_888_545_440_768,
    magic: 72_058_420_829_626_496,
    shift: 55,
  ),
  magics.MagicEntry(
    mask: 1_135_039_602_493_440,
    magic: 873_700_527_809_101_828,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 2_269_529_440_784_384,
    magic: 2_749_518_348_304,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 4_539_058_881_568_768,
    magic: 1_157_463_587_443_769_344,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 1_128_098_963_916_800,
    magic: 18_087_106_132_312_130,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_256_197_927_833_600,
    magic: 1_725_150_934_335_489,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 4_514_594_912_477_184,
    magic: 18_016_881_805_918_216,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 9_592_139_778_506_752,
    magic: 144_115_308_335_071_233,
    shift: 55,
  ),
  magics.MagicEntry(
    mask: 19_184_279_556_981_248,
    magic: 585_611_442_129_567_745,
    shift: 55,
  ),
  magics.MagicEntry(
    mask: 2_339_762_086_609_920,
    magic: 72_132_919_711_899_784,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 4_538_784_537_380_864,
    magic: 9_367_629_079_378_989_056,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 9_077_569_074_761_728,
    magic: 2_750_934_951_936,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 562_958_610_993_152,
    magic: 9_025_959_806_107_664,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 1_125_917_221_986_304,
    magic: 576_480_200_049_639_424,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_814_792_987_328_512,
    magic: 666_533_023_100_977_156,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 5_629_586_008_178_688,
    magic: 1_152_956_693_424_902_144,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 11_259_172_008_099_840,
    magic: 73_184_322_877_669_888,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 22_518_341_868_716_544,
    magic: 1_801_442_618_047_996_422,
    shift: 57,
  ),
  magics.MagicEntry(
    mask: 9_007_336_962_655_232,
    magic: 1_702_078_460_755_968,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 18_014_673_925_310_464,
    magic: 1_297_045_493_073_051_936,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_216_338_399_232,
    magic: 2_305_847_476_063_862_784,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 4_432_676_798_464,
    magic: 2_201_372_344_328,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 11_064_376_819_712,
    magic: 144_326_345_999_056_900,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 22_137_335_185_408,
    magic: 4_612_249_174_551_986_180,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 44_272_556_441_600,
    magic: 9_007_199_556_861_984,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 87_995_357_200_384,
    magic: 871_446_665_354_086_400,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 35_253_226_045_952,
    magic: 1_441_239_884_773_261_312,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 70_506_452_091_904,
    magic: 285_909_535_178_786,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 567_382_630_219_776,
    magic: 9_259_407_432_571_437_473,
    shift: 58,
  ),
  magics.MagicEntry(
    mask: 1_134_765_260_406_784,
    magic: 1_156_343_210_707_060_737,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 2_832_480_465_846_272,
    magic: 289_356_550_953_763_330,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 5_667_157_807_464_448,
    magic: 13_844_214_842_342_310_912,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 11_333_774_449_049_600,
    magic: 1_196_268_654_166_281,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 22_526_811_443_298_304,
    magic: 1_875_890_540_672_188_936,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 9_024_825_867_763_712,
    magic: 1_157_425_234_325_274_880,
    shift: 59,
  ),
  magics.MagicEntry(
    mask: 18_049_651_735_527_936,
    magic: 72_215_992_448_602_832,
    shift: 58,
  ),
]

pub type MoveTables {
  MoveTables(
    white_pawn_targets: tables.TableGetter(Int),
    black_pawn_targets: tables.TableGetter(Int),
    white_pawn_capture_targets: tables.TableGetter(Int),
    black_pawn_capture_targets: tables.TableGetter(Int),
    knight_targets: tables.TableGetter(Int),
    king_targets: tables.TableGetter(Int),
    rook_moves: fn(square.Square, Int) -> Int,
    bishop_moves: fn(square.Square, Int) -> Int,
    queen_moves: fn(square.Square, Int) -> Int,
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

  let rook_moves = generate_magic_tables(rook_move_shifts, rook_magics)
  let bishop_moves = generate_magic_tables(bishop_move_shifts, bishop_magics)

  let rook_magics = glearray.from_list(rook_magics)
  let bishop_magics = glearray.from_list(bishop_magics)

  let rook_getter = fn(square: square.Square, blockers: Int) -> Int {
    let i = square |> square.index
    let assert Ok(magic) = rook_magics |> glearray.get(i)
    let assert Ok(moves) = rook_moves |> glearray.get(i)
    let assert Ok(targets) =
      moves |> glearray.get(magics.magic_index(magic, blockers))
    targets
  }
  let bishop_getter = fn(square: square.Square, blockers: Int) -> Int {
    let i = square |> square.index
    let assert Ok(magic) = bishop_magics |> glearray.get(i)
    let assert Ok(moves) = bishop_moves |> glearray.get(i)
    let assert Ok(targets) =
      moves |> glearray.get(magics.magic_index(magic, blockers))
    targets
  }
  let queen_getter = fn(square, blockers) {
    int.bitwise_or(
      rook_getter(square, blockers),
      bishop_getter(square, blockers),
    )
  }

  MoveTables(
    white_pawn_targets: white_pawn_getter,
    black_pawn_targets: black_pawn_getter,
    white_pawn_capture_targets: white_pawn_capture_getter,
    black_pawn_capture_targets: black_pawn_capture_getter,
    knight_targets: knight_getter,
    king_targets: king_getter,
    rook_moves: rook_getter,
    bishop_moves: bishop_getter,
    queen_moves: queen_getter,
  )
}

pub fn sliding_targets(
  square: square.Square,
  blockers: Int,
  shifts: List(Int),
  include_edges: Bool,
) {
  let index = square.index(square)

  let targets =
    shifts
    |> list.map(fn(shift) { slide_recursive(index, shift, blockers) })
    |> list.fold(0, int.bitwise_or)

  case include_edges {
    True -> targets
    False -> targets |> remove_edges(index)
  }
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

fn generate_magic_tables(
  deltas: List(Int),
  magics: List(magics.MagicEntry),
) -> glearray.Array(glearray.Array(Int)) {
  square.all_squares
  |> list.zip(magics)
  |> list.map(fn(data) {
    let square = data.0
    let entry = data.1
    generate_table(square, deltas, entry)
  })
  |> glearray.from_list
}

fn generate_table(
  square: square.Square,
  deltas: List(Int),
  entry: magics.MagicEntry,
) -> glearray.Array(Int) {
  let ordered_entries =
    entry.mask
    |> bitboard.map_subsets(fn(blockers) {
      let moves = sliding_targets(square, blockers, deltas, True)
      let index = magics.magic_index(entry, blockers)
      #(moves, index)
    })
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) |> order.negate })

  ordered_entries
  |> list.fold([], fn(acc, entry) {
    let moves = entry.0
    let index = entry.1
    let new_table = acc |> grow_list(0, index - 1) |> list.reverse
    [moves, ..new_table] |> list.reverse
  })
  |> glearray.from_list
}

pub fn grow_list(list, val, desired) {
  let len = list.length(list)
  grow_list_inner(list.reverse(list), val, desired, len)
}

fn grow_list_inner(list, val, desired_length, current_length) {
  case int.compare(current_length, desired_length) {
    order.Eq -> list.reverse(list)
    order.Gt -> list.reverse(list)
    order.Lt ->
      grow_list_inner([val, ..list], val, desired_length, current_length + 1)
  }
}

pub fn remove_edges(mask: Int, start: Int) {
  let rank = square.rank(start)
  let file = square.file(start)

  mask
  |> int.bitwise_and(
    int.bitwise_not(case rank {
      // apply only 8th rank filter
      0 -> 0xff00000000000000
      // apply only 1st rank filter
      7 -> 0xff
      // apply both
      _ -> int.bitwise_or(0xff, 0xff00000000000000)
    }),
  )
  |> int.bitwise_and(
    int.bitwise_not(case file {
      // apply only H file filter
      0 -> 0x8080808080808080
      // apply only A file filter
      7 -> 0x101010101010101
      // apply both
      _ -> int.bitwise_or(0x101010101010101, 0x8080808080808080)
    }),
  )
}
