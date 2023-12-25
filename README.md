S369 - 2048 Bit Symetric Block Cipher Algorithm

[Intro]
-------
    S369 is 2048 bit symetric block cipher algorithm. Key & data size are equal.
S369 is designed primarily for "quantum doomsday". Algorithm uses 2048 bit
keys (256 byte) to make hard to crack for all cryptoanalysis methods and brute force attacks.
    S369 has 12 rounds, key-dependent s-boxes and uses key dependent data permutations.
S369 is slower against many other ciphers because of bit & byte level pemutation
operations.
    S369 has 2, 4 bit "GOST-borrowed" s-boxes for initial confusion properties. 
Later in key schedule 8 bit (256 member) key-dependent s-box generated.
S369 has also very slow key schedule. 12 round key and 1 8 bit s-box generated during schedule.
S369 operates on 8 bit unsigned integers.

[Key Schedule]
--------------
    Note #1 - Initial 8 bit S-Box and Initalization Vector(IV) block is numbers from 0 to 255

Step #1 - Fusing Key to Initalization Vector(IV)
> Every member of IV is exclusive-or'ed with corresponding key data. To amplify bit differences
result bits are rotated (logical not)
> Key length is the step limit for operation above.

Step #2 - Iteration Of Initalization Vector (IV)
    Note #1 - Iteration is repeated 3 times for every key generation.
> Below, operation graphic example is better to understand procedure (with 8 byte array example)
> (+) is not mathematical operator. Resembles one-line iteration procedure.

    # Example IV array
    IV[0] IV[1] IV[2] IV[3] IV[4] IV[5] IV[6] IV[7]

    # Repeated for 3 times
        IV[1] = IV[0] + IV[1]
        IV[2] = IV[1] + IV[2]
        IV[3] = IV[2] + IV[3]
        IV[4] = IV[3] + IV[4]
        IV[5] = IV[4] + IV[5]
        IV[6] = IV[5] + IV[6]
        IV[7] = IV[6] + IV[7]
        IV[0] = IV[7] + IV[0] (Circular return point for furter iterations)

    # (+) Operation - Explained

    ! - Lets calculate for IV[1] = IV[0] + IV[1]

    Note #2 - There are 2, 4 bit S-boxes known as "Sx" and "Sy".
    Definition of these boxes are in the source code.

    #Example Pseudo Code

    IV[1] = IV[0] xor ( 
                        ((Sx[IV[1]_2] + Sx[IV[1]_1]) mod 0x10) 
                        (+)
                        ((Sy[IV[1]_2] + Sy[IV[1]_1]) mod 0x10)
                      )  
    
        Note #1 - "(+)" is Fusing 2, 4 bit byte halves.
        Note #2 - "_1" is first 4 bit halve of byte
        Note #3 - "_2" is second 4 bit halve of byte
        Note #4 - "+" sign (without colons) is aritmetic adding
        Note #5 - Results cropped with modulo 0x10 (decimal 16)
        Note #6 - Sx[], Sy[] is 4 byte substitution value finding 
                  operation for key schedule
        Note #7 - "xor" is bitwise "exclusive or" operation

Step #3 - Generation Of Round Keys 

> Nothing special here, calculation defined above is used 12 times to generate key array.
Every key is 2048 bit/256 byte. Array has 12 members as round count.
Note ! - After Step #4, all keys generated are replaced with substitutes from 8 bit s-box to 
         finalize key generation. This provides different key sets for key schedule and encryption.

Step #4 - 8 Bit Key-Dependent Substitution Box calculation

> This step is quite easy. 12 keys used with special order to mix byte members of s-box.

# Key usage order
  1-2, 2-3, 3-4, 4-5, 5-6, 6-7, 7-8, 8-9, 9-10, 10-11, 11-12

  # Example Pseudo Code
  for i = 1 to 11
  {
    a = sbox[key[i]]
    b = sbox[key[i+1]]
    sbox[key[i]] = b
    sbox[key[i+1]] = a    
  }

[Encryption]
------------
Step #1 - Data xor'ed with corresponding key

Step #2 - Data substitution is applied with key-dependent 8 bit s-box

Step #3 - Key Dependent Data permutations

    Note #1 - This step is the most complex and slow step of this algorithm. But also makes
    this algorithm strong. Mixing byte halves and bit shifting applied to complete operation.

    (Sub Steps Of Step #3)
    **********************
    > ! Explained with Pseudo Code

    for i = 1 to 11 
    {
      for j = 1 to 255 - 1 
      {
        #1 - First, 2 value chosen from data array with corresponding round key.
             "a" and "b" will be evaluated as 2 byte halves. (a2a1), (b2b1)
        
        a = Data[key[i][j]]
        b = Data[key[i][j+1]]
        
        #2 - "a" and "b" divied to 4 bit byte halves, and linearly mixed as such below
        
            Temprorary array value : a2a1b2b1

        #3 - Temprorary value's first halve shifted to end of array. Should look like this;

            Temprorary array value : a1b2b1a2

        #4 - Shifted havles again joined together as below

        a = a1b2
        b = b1a2

        #5 - Value "a" and "b" gets bit shifted 1 bit right (with carrying least significant bit)
        
        a = a >> 1
        b = b >> 1

      }
    }

    !Note: Step 1,2,3 is repeated 12 times (as round count) before Step #4

Step #4 - Step#2 Re-applied. And Encryption finishes.
