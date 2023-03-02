//
//  NSData+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/29.
//

#import "NSData+SLChainable.h"
#import "SLFoundationPrivate.h"

#define SWAP(a,b) {uint32_t t = a; a = b; b = t; t = 0;}

static const uint32_t SM4_FK[4] = { 0xA3B1BAC6, 0x56AA3350, 0x677D9197, 0xB27022DC};

static const uint32_t SM4_CK[32] = {
    0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269, 0x70777e85, 0x8c939aa1, 0xa8afb6bd, 0xc4cbd2d9,
    0xe0e7eef5, 0xfc030a11, 0x181f262d, 0x343b4249, 0x50575e65, 0x6c737a81, 0x888f969d, 0xa4abb2b9,
    0xc0c7ced5, 0xdce3eaf1, 0xf8ff060d, 0x141b2229, 0x30373e45, 0x4c535a61, 0x686f767d, 0x848b9299,
    0xa0a7aeb5, 0xbcc3cad1, 0xd8dfe6ed, 0xf4fb0209, 0x10171e25, 0x2c333a41, 0x484f565d, 0x646b7279
};

uint8_t SM4_SBOX[256] = {
    0xd6, 0x90, 0xe9, 0xfe, 0xcc, 0xe1, 0x3d, 0xb7, 0x16, 0xb6, 0x14, 0xc2, 0x28, 0xfb, 0x2c, 0x05,
    0x2b, 0x67, 0x9a, 0x76, 0x2a, 0xbe, 0x04, 0xc3, 0xaa, 0x44, 0x13, 0x26, 0x49, 0x86, 0x06, 0x99,
    0x9c, 0x42, 0x50, 0xf4, 0x91, 0xef, 0x98, 0x7a, 0x33, 0x54, 0x0b, 0x43, 0xed, 0xcf, 0xac, 0x62,
    0xe4, 0xb3, 0x1c, 0xa9, 0xc9, 0x08, 0xe8, 0x95, 0x80, 0xdf, 0x94, 0xfa, 0x75, 0x8f, 0x3f, 0xa6,
    0x47, 0x07, 0xa7, 0xfc, 0xf3, 0x73, 0x17, 0xba, 0x83, 0x59, 0x3c, 0x19, 0xe6, 0x85, 0x4f, 0xa8,
    0x68, 0x6b, 0x81, 0xb2, 0x71, 0x64, 0xda, 0x8b, 0xf8, 0xeb, 0x0f, 0x4b, 0x70, 0x56, 0x9d, 0x35,
    0x1e, 0x24, 0x0e, 0x5e, 0x63, 0x58, 0xd1, 0xa2, 0x25, 0x22, 0x7c, 0x3b, 0x01, 0x21, 0x78, 0x87,
    0xd4, 0x00, 0x46, 0x57, 0x9f, 0xd3, 0x27, 0x52, 0x4c, 0x36, 0x02, 0xe7, 0xa0, 0xc4, 0xc8, 0x9e,
    0xea, 0xbf, 0x8a, 0xd2, 0x40, 0xc7, 0x38, 0xb5, 0xa3, 0xf7, 0xf2, 0xce, 0xf9, 0x61, 0x15, 0xa1,
    0xe0, 0xae, 0x5d, 0xa4, 0x9b, 0x34, 0x1a, 0x55, 0xad, 0x93, 0x32, 0x30, 0xf5, 0x8c, 0xb1, 0xe3,
    0x1d, 0xf6, 0xe2, 0x2e, 0x82, 0x66, 0xca, 0x60, 0xc0, 0x29, 0x23, 0xab, 0x0d, 0x53, 0x4e, 0x6f,
    0xd5, 0xdb, 0x37, 0x45, 0xde, 0xfd, 0x8e, 0x2f, 0x03, 0xff, 0x6a, 0x72, 0x6d, 0x6c, 0x5b, 0x51,
    0x8d, 0x1b, 0xaf, 0x92, 0xbb, 0xdd, 0xbc, 0x7f, 0x11, 0xd9, 0x5c, 0x41, 0x1f, 0x10, 0x5a, 0xd8,
    0x0a, 0xc1, 0x31, 0x88, 0xa5, 0xcd, 0x7b, 0xbd, 0x2d, 0x74, 0xd0, 0x12, 0xb8, 0xe5, 0xb4, 0xb0,
    0x89, 0x69, 0x97, 0x4a, 0x0c, 0x96, 0x77, 0x7e, 0x65, 0xb9, 0xf1, 0x09, 0xc5, 0x6e, 0xc6, 0x84,
    0x18, 0xf0, 0x7d, 0xec, 0x3a, 0xdc, 0x4d, 0x20, 0x79, 0xee, 0x5f, 0x3e, 0xd7, 0xcb, 0x39, 0x48
};
/**
 * 将一个32bit数转换为 4 Byte的数组 eg.0x01234567 => {0x01, 0x23, 0x45, 0x67}
 */
static void _uInt32ToBytes(const uint32_t _in, uint8_t *_out) {
    for (int i=0; i<4; i++) {
        _out[i] = (uint8_t)(_in >> (8*(3-i)));
    }
}
/**
 * 将一个 4 Byte的数组转换为一个32bit的数   eg.{0x01, 0x23, 0x45, 0x67} => 0x01234567
 *
 */
static void _bytesToUint32(const uint8_t *_in, uint32_t *_out) {
    *_out = 0x0;
    for (int i=3; i>=0; i--) {
        *_out = (*_out) | (((uint32_t)_in[i]) << (8*(3-i)));
    }
}

static uint32_t _rol32(uint32_t _in, int n) {
    return (_in << n) | (_in >> (32-n));
}

/**
 * 将 sm4的16字节key变换
 */
static void _setSm4Key(const uint8_t intKey[16], uint32_t outKey[32]) {
    // 1、将16Byte分为四组；每组4Byte，高位在前，低位在后，组装成一个 32bit 数
    uint32_t mk[4];
    for (int i=0; i<4; i++) {
        _bytesToUint32(intKey+(4*i), mk+i);
    }
    
    // 2、将 步骤1 得到的4个数与 固定表 进行一个异或
    uint32_t k[36];
    for (int i=0; i<4; i++) {
        k[i] = mk[i] ^ SM4_FK[i];
    }
    
    // 3、
    uint32_t temp_k;
    uint8_t temp_k_bytes[4];
    for (int i=0; i<32; i++) {
        // 将k循环异或
        temp_k = k[i+1] ^ k[i+2] ^ k[i+3];
        // 再将循环异或后的结果和 固定表 异或
        temp_k = temp_k ^ SM4_CK[i];
        // 将上一步得到的数转化为Byte数组
        _uInt32ToBytes(temp_k, temp_k_bytes);
        // 用上一步的到的Byte数组作为下标，进行 固定表 查询
        temp_k_bytes[0] = SM4_SBOX[temp_k_bytes[0]];
        temp_k_bytes[1] = SM4_SBOX[temp_k_bytes[1]];
        temp_k_bytes[2] = SM4_SBOX[temp_k_bytes[2]];
        temp_k_bytes[3] = SM4_SBOX[temp_k_bytes[3]];
        // 将查表后的Byte数组转换为 32位数
        _bytesToUint32(temp_k_bytes, &temp_k);
        // 将原数 异或 【循环左移13为】 异或 【循环左移23位】
        temp_k = temp_k ^ _rol32(temp_k, 13) ^ _rol32(temp_k, 23);
        // 将得到的数，再与k[i] 异或
         temp_k = temp_k ^ k[i];
        
        // 得到最终的key[i]
        k[i+4] = temp_k;
        outKey[i] = temp_k;
    }
}

void _sm4_one_round(const uint32_t sk[32], const uint8_t input[16], uint8_t output[16]) {
    
    uint32_t ulbuf[36];
    uint32_t tempO;
    uint8_t tempBytes[4];
    // 置零
    memset(ulbuf, 0, sizeof(ulbuf));
    // 将待加密数据按照4Byte一组进行分组，并组装为uint32类型数。【高位在前，低位在后————大端】
    for (int i=0; i<4; i++) {
        _bytesToUint32(input+(4*i), ulbuf+i);
    }
    
    for (int j = 0; j<32; j++) {
        tempO = ulbuf[j+1] ^ ulbuf[j+2] ^ ulbuf[j+3] ^ sk[j];
        _uInt32ToBytes(tempO, tempBytes);
        for (int n=0; n<4; n++) {
            tempBytes[n] = SM4_SBOX[tempBytes[n]];
        }
        _bytesToUint32(tempBytes, &tempO);
        tempO = tempO ^ _rol32(tempO, 2) ^ _rol32(tempO, 10) ^ _rol32(tempO, 18) ^ _rol32(tempO, 24);
        tempO = tempO ^ ulbuf[j];
        ulbuf[j+4] = tempO;
    }
    for (int o=0; o<4; o++) {
        // 反序输出
        _uInt32ToBytes(ulbuf[35-o], output+(o*4));
    }
}

@implementation NSData (SLChainable)

- (SLChainableNSDataEmptyBlock)base64Encode {
    SL_CHAINABLE_EMPTY_BLOCK(return [self _base64Encode];);
}

- (SLChainableNSDataEmptyBlock)base64Decode {
    SL_CHAINABLE_EMPTY_BLOCK(return [self _base64Decode];);
}

- (SLChainableNSDataObjectBlock)sm4EcbEncrypt {
    return ^(NSData *keyData){
        
        uint32_t sk[32];
        _setSm4Key((const uint8_t *)keyData.bytes, sk);
        // 计算填充位数
        uint8_t padding = 16-(self.length%16);
        // 填充 【填充规则-】
        NSMutableData *paddingData = [[NSMutableData alloc] initWithLength:self.length+padding];
        memcpy(paddingData.mutableBytes, self.bytes, self.length);
        for (int i=0; i<padding; i++) {
            ((uint8_t *)paddingData.mutableBytes)[self.length+i] = padding;
        }
        
        NSMutableData *retData = [[NSMutableData alloc] initWithLength:paddingData.length];
        
        long dataLen = paddingData.length;
        uint8_t *input = (uint8_t *)paddingData.bytes;
        uint8_t *output = (uint8_t *)retData.mutableBytes;
        
        // 加密
        while (dataLen > 0) {
            _sm4_one_round(sk, input, output);
            input += 16;
            output += 16;
            dataLen -= 16;
        }
        
        return [retData copy];
    };
}

- (SLChainableNSDataObjectBlock)sm4EcbDecrypt {
    return ^(NSData *keyData) {
        // 设置key
        uint32_t sk[32];
        _setSm4Key((const uint8_t *)keyData.bytes, sk);
        for(int i = 0; i < 16; i ++ ) {
            SWAP( sk[i], sk[31-i]);
        }
        
        // 解密
        long dataLen = (long)self.length;
        NSMutableData *retData = [[NSMutableData alloc] initWithLength:dataLen];
        uint8_t *input = (uint8_t *)self.bytes;
        uint8_t *output = (uint8_t *)retData.bytes;
        while (dataLen > 0) {
            _sm4_one_round(sk, input, output);
            input += 16;
            output += 16;
            dataLen -= 16;
        }
        // 查找补位数
        uint8_t padding = ((uint8_t *)retData.bytes)[self.length-1];
        return [NSData dataWithBytes:retData.bytes length:self.length-padding];
    };
}

- (SLChainableNSDataTwoObjectBlock)sm4CbcEncrypt {
    return ^(NSData *keyData, NSData *ivData) {
        uint8_t *keyBytes = (uint8_t *)keyData.bytes;
        
        return [NSData new];
    };
}

@end
