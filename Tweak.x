/* * ==============================================================================
 * 🛡️ BẢN QUYỀN ĐỘC QUYỀN: PHẠM HẢI LONG
 * 💎 PHIÊN BẢN: IZANAGI V16 - SUPREME MASTER (OB52)
 * 👁️ CƠ CHẾ: HEX MEMORY PATCHING (KHÔNG CẦN SUBSTRATE)
 * ⚙️ GESTURE: 3 NGÓN TAY CHẠM 2 LẦN ĐỂ MỞ MENU
 * ==============================================================================
 */

#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <vector>

// --- SIÊU KHỐI DỮ LIỆU TẠO ĐỘ NẶNG (120MB) ---
unsigned char long_prime_data[1024 * 1024 * 120] = {0x50, 0x48, 0x41, 0x4d, 0x4c, 0x4f, 0x4e, 0x47};

// Biến điều khiển hệ thống
bool isAuthorized = true;
bool bHeadshot = false;
bool bDanThang = false; // Bao gồm Nhẹ Tâm & Đạn Thẳng
bool bAntiban = true;
bool bTangNhay = false;

// --- HÀM CAN THIỆP BỘ NHỚ (CORE INJECTOR) ---
void patch_ram(uintptr_t address, const char* hex_code, size_t size) {
    kern_return_t kr;
    mach_port_t self = mach_task_self();
    kr = vm_protect(self, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr == KERN_SUCCESS) {
        memcpy((void*)address, hex_code, size);
        vm_protect(self, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// --- GIAO DIỆN MENU PHẠM HẢI LONG ---
@interface IzanagiV16 : UIView
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation IzanagiV16
static IzanagiV16 *sharedInstance = nil;

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        sharedInstance = [[IzanagiV16 alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:sharedInstance];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
        tap.numberOfTapsRequired = 2; tap.numberOfTouchesRequired = 3;
        [self addGestureRecognizer:tap];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 480)];
    self.panel.center = self.center;
    self.panel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.96];
    self.panel.layer.borderColor = [UIColor redColor].CGColor;
    self.panel.layer.borderWidth = 3.0; self.panel.layer.cornerRadius = 25;
    self.panel.hidden = YES;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
    title.text = @"⚡ IZANAGI MASTER V16 👁️"; title.textColor = [UIColor redColor];
    title.textAlignment = NSTextAlignmentCenter; title.font = [UIFont boldSystemFontOfSize:22];
    [self.panel addSubview:title];

    // Nút chức năng
    [self addButton:@"🎯 FULL HEADSHOT 100%" y:80 tag:1];
    [self addButton:@"🌀 ĐẠN THẲNG - NHẸ TÂM" y:150 tag:2];
    [self addButton:@"⚡ TĂNG NHẠY CẢM ỨNG" y:220 tag:3];
    [self addButton:@"🛡️ ANTIBAN & NO REPORT" y:290 tag:4];

    UILabel *cr = [[UILabel alloc] initWithFrame:CGRectMake(0, 440, 300, 20)];
    cr.text = @"DEV: PHẠM HẢI LONG - 0968166218"; cr.textColor = [UIColor yellowColor];
    cr.textAlignment = NSTextAlignmentCenter; cr.font = [UIFont systemFontOfSize:11];
    [self.panel addSubview:cr];

    [self addSubview:self.panel];
}

- (void)addButton:(NSString *)title y:(int)y tag:(int)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(25, y, 250, 50);
    [btn setTitle:[title stringByAppendingString:@": OFF"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor darkGrayColor]; btn.layer.cornerRadius = 12; btn.tag = tag;
    [btn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:btn];
}

- (void)actionClick:(UIButton *)btn {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    if (btn.tag == 1) {
        bHeadshot = !bHeadshot;
        if (bHeadshot) patch_ram(base + 0x3B2A150, "\x20\x00\x80\xD2\xC0\x03\x5F\xD6", 8); // Force Headshot
    }
    if (btn.tag == 2) {
        bDanThang = !bDanThang;
        if (bDanThang) patch_ram(base + 0x2D1A550, "\x00\x00\x20\xD2\xC0\x03\x5F\xD6", 8); // No Spread/Recoil
    }
    if (btn.tag == 4) {
        bAntiban = !bAntiban;
        if (bAntiban) patch_ram(base + 0x4A2B1C0, "\xC0\x03\x5F\xD6", 4); // Anti-Report Bypass
    }

    [btn setBackgroundColor:(btn.backgroundColor == [UIColor redColor] ? [UIColor darkGrayColor] : [UIColor redColor])];
    NSString *st = [btn.titleLabel.text containsString:@"OFF"] ? @"ON" : @"OFF";
    [btn setTitle:[[btn.titleLabel.text componentsSeparatedByString:@":"][0] stringByAppendingFormat:@": %@", st] forState:UIControlStateNormal];
}

- (void)toggleMenu {
    self.panel.hidden = !self.panel.hidden;
    self.userInteractionEnabled = !self.panel.hidden;
}
@end
