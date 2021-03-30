import logging
import os
import sys
import re
import mpmath as math

from preprocess.utils import mathcalculator


def groupVariant(variantInfo):
    '''
    group the items by binned_GQ, validPL, depth(min30p3a strategy)
    return iterable object
    '''

    cur_list, cur_gq_bin_index, cur_valid_PL, cur_min_DP, cur_max_DP, cur_chr = ([], None, None, None, None, None)

    for cur_item in variantInfo:
        _gq_bin = cur_item['binned_gq']
        _gt = cur_item["gt"]
        _DP = cur_item["min_dp"]
        _chr = cur_item['chr']
        if (cur_gq_bin_index == None):

            # the first item of the variantInfo
            cur_list, cur_gq_bin_index, cur_gt, cur_min_DP, cur_max_DP, cur_chr = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr)

        elif (_gq_bin != cur_gq_bin_index):

            yield cur_list, cur_min_DP
            cur_list, cur_gq_bin_index, cur_gt, cur_min_DP, cur_max_DP, cur_chr = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr)

        elif (_gt != cur_gt):
            # _valid_PL need to be same, which means "./." and "0/0" should not be merged in one block
            yield cur_list, cur_min_DP
            cur_list, cur_gq_bin_index, cur_gt, cur_min_DP, cur_max_DP, cur_chr = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr)

        else:

            # ignor DP version
            cur_list.append(cur_item)
            if (_DP < cur_min_DP):
                cur_min_DP = _DP

    if (len(cur_list) > 0):
        yield cur_list, cur_min_DP


class gvcfGenerator(object):

    def __init__(self, ref_path, samtools='samtools'):

        self.reference_file_path = ref_path
        self.samtools = samtools

        '''
        self.ctgName = ctgName
        self.ctgStart = ctgStart
        self.ctgEnd = ctgEnd
        self.bamPath = bamPath
        self.tmpDir = tmpDir
        
        # got RG ID
        # might be 
        extract_RG_cmd = 'samtools view -H '+self.bamPath+'| grep @RG' 
        RG_info = os.popen(extract_RG_cmd).readline()
        self.RG_ID = RG_info.split("\t")[1].split(':')[1] 
        '''

        pass

    def readCalls(self, callPath, callType='variant', ctgName=None, ctgStart=None, ctgEnd=None):

        with open(callPath, 'r') as reader:
            for line in reader:
                if (line.startswith('#')):
                    continue
                else:
                    if (callType == 'non-variant'):
                        cur_non_variant_start = int(line.strip('\n').split('\t')[1])
                        cur_non_variant_end = int(re.search(r'.*END=(.*)\tGT.*', line).group(1))
                        cur_non_variant_chr = line.strip('\n').split('\t')[0]
                        if ((ctgName and cur_non_variant_chr == ctgName) or (not ctgName)):
                            if ((ctgStart and cur_non_variant_start >= ctgStart) or (not ctgStart)):
                                if ((ctgEnd and cur_non_variant_end <= ctgEnd) or (not ctgEnd)):
                                    yield line.strip('\n'), cur_non_variant_start, cur_non_variant_end, 'original'
                    else:
                        # for variant calls, return "pos"
                        # DEL and INS should be considered here
                        tmp = line.strip('\n').split('\t')
                        ref = tmp[3]
                        alt = tmp[4]
                        n_alt = len(alt.split(','))
                        cur_variant_start = int(line.strip('\n').split('\t')[1])
                        cur_variant_end = cur_variant_start - 1 + len(ref)

                        # add <*> to variant calls
                        tmp[4] = tmp[4] + ',<*>'
                        if (n_alt == 1):

                            tmp[-1] = tmp[-1] + ',990,990,990'

                        elif (n_alt == 2):
                            tmp[-1] = tmp[-1] + ',990,990,990,990'
                        new_line = '\t'.join(tmp)

                        cur_variant_chr = tmp[0]
                        # TODO: Add "PASS" or "LowQual" here

                        if ((ctgName and cur_variant_chr == ctgName) or (not ctgName)):
                            if ((ctgStart and cur_variant_start >= ctgStart) or (not ctgStart)):
                                if ((ctgEnd and cur_variant_end <= ctgEnd) or (not ctgEnd)):
                                    yield new_line, cur_variant_start, cur_variant_end

    def _print_vcf_header(self, save_writer, sampleName):

        from textwrap import dedent
        print(dedent("""\
            ##fileformat=VCFv4.2
            ##FILTER=<ID=PASS,Description="All filters passed">
            ##FILTER=<ID=LowQual,Description="Confidence in this variant being real is below calling threshold.">
            ##FILTER=<ID=RefCall,Description="Genotyping model thinks this site is reference.">
            ##ALT=<ID=DEL,Description="Deletion">
            ##ALT=<ID=INS,Description="Insertion of novel sequence">
            ##INFO=<ID=P,Number=0,Type=Flag,Description="Whether calling result from pileup calling">
            ##INFO=<ID=F,Number=0,Type=Flag,Description="Whether calling result from full alignment calling">
            ##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
            ##INFO=<ID=LENGUESS,Number=.,Type=Integer,Description="Best guess of the indel length">
            ##INFO=<ID=END,Number=1,Type=Integer,Description="End position (for use with symbolic alleles)">
            ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
            ##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
            ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
            ##FORMAT=<ID=MIN_DP,Number=1,Type=Integer,Description="Minimum DP observed within the GVCF block.">
            ##FORMAT=<ID=PL,Number=G,Type=Integer,Description="Phred-scaled genotype likelihoods rounded to the closest integer">
            ##FORMAT=<ID=AF,Number=1,Type=Float,Description="Estimated allele frequency in the range (0,1)">"""), file=save_writer)
        if self.reference_file_path is not None:
            reference_index_file_path = self.reference_file_path + ".fai"
            with open(reference_index_file_path, "r") as fai_fp:
                for row in fai_fp:
                    columns = row.strip().split("\t")
                    contig_name, contig_size = columns[0], columns[1]
                    print("##contig=<ID=%s,length=%s>" % (contig_name, contig_size), file=save_writer)

        print('#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t%s' % (sampleName), file=save_writer)

        pass

    def readReferenceBaseAtPos(self, pos):

        cmd = self.samtools + ' faidx ' + self.reference_file_path + ' ' + pos

        reader = os.popen(cmd)
        for line in reader:
            if (line.startswith('>')):
                continue
            else:
                ref_base = line.strip('\n').upper()
                return ref_base

    def _writeRightBlock(self, block_new_start, curNonVarEnd, curNonVarCall, save_writer):

        pos_cmd = str(curNonVarCall.split('\t')[0]) + ':' + str(block_new_start) + '-' + str(block_new_start)
        new_ref = self.readReferenceBaseAtPos(pos_cmd)
        tmp = curNonVarCall.split('\t')
        tmp[1] = str(block_new_start)
        tmp[3] = str(new_ref)
        print('\t'.join(tmp), file=save_writer)

    def _writeLeftBlock(self, end_pos, curNonVarCall, save_writer):

        new_left_block = re.sub("END=[0-9]*\t", "END=" + str(end_pos) + '\t', curNonVarCall)
        print(new_left_block, file=save_writer)
        pass

    def writeNonVarBlock(self, start, end, pos_flag, curNonVarCall, save_writer):

        if (pos_flag == 'left'):
            self._writeLeftBlock(end, curNonVarCall, save_writer)
        elif (pos_flag == 'right'):
            self._writeRightBlock(start, end, curNonVarCall, save_writer)
        else:
            print(curNonVarCall, file=save_writer)

    def mergeCalls(self, variantCallPath, nonVarCallPath, savePath, sampleName, ctgName=None, ctgStart=None,
                   ctgEnd=None):

        '''

        merge calls between variant and non-variant
        
        '''

        varCallStop = False
        nonVarCallStop = False
        printCurVar = True
        varCallGenerator = self.readCalls(variantCallPath, 'variant', ctgName, ctgStart, ctgEnd)
        nonVarCallGenerator = self.readCalls(nonVarCallPath, 'non-variant', ctgName, ctgStart, ctgEnd)
        hasVar = True
        # in case of empty file
        try:
            curVarCall, curVarStart, curVarEnd = next(varCallGenerator)
        except StopIteration:
            varCallStop = True
            hasVar = False
        try:
            curNonVarCall, curNonVarStart, curNonVarEnd, curNonVarPos = next(nonVarCallGenerator)
        except StopIteration:
            nonVarCallStop = True
        save_writer = open(savePath, 'w')
        # print gvcf header
        self._print_vcf_header(save_writer, sampleName)
        while True and (not varCallStop) and (not nonVarCallStop):
            if (curNonVarEnd < curVarStart):

                '''
                |____|   {____}
                 nonVar    Var
                nonVar region is on the left, no overlapped region
                '''
                # print(curNonVarCall,file=save_writer)
                self.writeNonVarBlock(curNonVarStart, curNonVarEnd, curNonVarPos, curNonVarCall, save_writer)
                # move non variant calls to the next
                try:
                    curNonVarCall, curNonVarStart, curNonVarEnd, curNonVarPos = next(nonVarCallGenerator)
                except StopIteration:
                    nonVarCallStop = True
                    break
            elif (curVarEnd < curNonVarStart):
                '''
                {____}     |____|
                 Var         nonVar
                var region is on the left, no overlapped region
                '''
                # print("{_____} |_____|")
                print(curVarCall, file=save_writer)
                try:
                    curVarCall, curVarStart, curVarEnd = next(varCallGenerator)
                except StopIteration:
                    varCallStop = True
                    break

            elif (curVarStart <= curNonVarStart and curVarEnd >= curNonVarStart):
                '''
                {____|____}___|
                or
                {____|_______|____}
                the left point of nonvar block can be included
                var region is on the left, has overlapped region
                '''
                # write the current variant Call
                print(curVarCall, file=save_writer)
                block_new_start = curVarEnd + 1
                try:
                    curVarCall, curVarStart, curVarEnd = next(varCallGenerator)
                except StopIteration:
                    varCallStop = True
                    break

                while (block_new_start > curNonVarEnd):
                    # skip the non-variant block within the current variant block

                    try:

                        curNonVarCall, curNonVarStart, curNonVarEnd, curNonVarPos = next(nonVarCallGenerator)
                    except StopIteration:
                        nonVarCallStop = True
                        break

                if (nonVarCallStop):
                    break

                # check if the start of the current non-variant block
                if ((block_new_start - 1) >= curNonVarStart):
                    # there is overlap between variants and non-variant block
                    # just write the right part of the non-variant block
                    curNonVarStart = block_new_start
                    curNonVarPos = 'right'

            elif (curVarStart > curNonVarStart):
                '''
                |_{__________________}__|
                or 
                |__{______________|____}
                '''
                # var call is within the non-var block
                # split the non-var block
                non_var_block_left_end = curVarStart - 1
                if (non_var_block_left_end >= curNonVarStart):
                    self._writeLeftBlock(non_var_block_left_end, curNonVarCall, save_writer)
                # print out variant call
                print(curVarCall, file=save_writer)
                # take care here, whether write the left right non-variant block,
                # it dependes on the position of the next variant calls 
                non_var_block_right_start = curVarEnd + 1

                try:
                    curVarCall, curVarStart, curVarEnd = next(varCallGenerator)
                except StopIteration:
                    varCallStop = True
                    break

                # still has the right left block
                if (non_var_block_right_start <= curNonVarEnd):
                    curNonVarStart = non_var_block_right_start
                    curNonVarPos = 'right'
                else:
                    # get the next non-variant block,skip the non-var block that is within the variant
                    while True:
                        try:
                            curNonVarCall, curNonVarStart, curNonVarEnd, curNonVarPos = next(nonVarCallGenerator)
                        except StopIteration:
                            nonVarCallStop = True
                            break
                        if (non_var_block_right_start <= curNonVarEnd):
                            break

                    if (nonVarCallStop):
                        break

                    curNonVarStart = non_var_block_right_start
                    curNonVarPos = 'right'

            else:
                print("[ERROR] CurVarStart", curVarStart, 'curVarEnd', curVarEnd, 'curNonVarStart', curNonVarStart,
                      'curNonVarEnd', curNonVarEnd)

        # printout the remain content
        if (not varCallStop):
            # print out the left

            print(curVarCall, file=save_writer)
            for curVarCall, curVarStart, curVarEnd in varCallGenerator:
                print(curVarCall, file=save_writer)
        if (not nonVarCallStop):
            if (hasVar and curNonVarEnd > curVarEnd):
                self.writeNonVarBlock(curVarEnd + 1, curNonVarEnd, curNonVarPos, curNonVarCall, save_writer)
            for curNonVarCall, curNonVarStart, curNonVarEnd, curNonVarPos in nonVarCallGenerator:
                print(curNonVarCall, file=save_writer)

        save_writer.close()


def _test_merge_gvcf(ref_path, vcf_path, gvcf_path, save_path, sample_name):
    myGvcfGenerator = gvcfGenerator(ref_path=ref_path)
    myGvcfGenerator.mergeCalls(vcf_path, gvcf_path, save_path, sample_name)


def _test_gvcf_generator():
    myGen = gvcfGenerator("./")
    x, y, z = next(myGen.readNonVariantCalls("tmp.g.vcf"))
    print(y, z)


class queueDict(object):

    def __init__(self):
        pass


class variantInfoCalculator(object):

    def __init__(self, gvcfWritePath, ref_path, p_err, gq_bin_size, bp_resolution=False, sample_name='None', mode='L'):

        # default p_error is 0.001, while it could be set by the users' option
        self.p_error = p_err
        self.LOG_10 = math.log(10.0)
        self.logp = math.log(self.p_error) / self.LOG_10
        self.log1p = math.log1p(-self.p_error) / self.LOG_10
        self.LOG_2 = math.log(2) / self.LOG_10
        # need to check with the clair3 settings
        self.max_gq = 255
        self.variantMath = mathcalculator()
        self.constant_log10_probs = self.variantMath.normalize_log10_prob([-1.0, -1.0, -1.0])
        # TODO: could be an option?, default is 5
        self.gq_bin_size = gq_bin_size
        # set by the users
        if (gvcfWritePath != "PIPE"):
            if (not os.path.exists(gvcfWritePath)):
                os.mkdir(gvcfWritePath)
            self.vcf_writer = open(os.path.join(gvcfWritePath, sample_name + '.tmp.g.vcf'), 'w')
        else:
            self.vcf_writer = sys.stdout
        self.writePath = gvcfWritePath
        self.sampleName = sample_name.split('.')[0]
        self.bp_resolution = bp_resolution
        self.reference_file_path = ref_path

        if (mode == 'L'):
            # dictionary to store constant log values for speeding up  
            self.normalized_prob_pool = {}

            self.current_block = []
            self._print_vcf_header()
            self.cur_gq_bin_index = None
            self.cur_gt = None
            self.cur_min_DP = None
            self.cur_max_DP = None
            self.cur_chr = None
            self.cur_raw_gq = None
        pass

    def make_gvcf_online(self, variant_summary, push_current=False):

        '''
        make gvcf while reading from pileup
        the difference is the other make_gvcf function receive a variant_summary generator 
        '''

        if (push_current):
            if (len(self.current_block) > 0):
                self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
                self.current_block = []
                self.cur_gq_bin_index = None
                self.cur_gt = None
                self.cur_min_DP = None
                self.cur_max_DP = None
                self.cur_chr = None
                self.cur_raw_gq = None
            return

        cur_item = self.reference_likelihood(variant_summary)
        _gq_bin = cur_item['binned_gq']
        _gt = cur_item["gt"]
        _DP = cur_item["min_dp"]
        _chr = cur_item['chr']
        _raw_gq = cur_item['gq']

        if (self.cur_gq_bin_index == None):
            self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
        elif (_gq_bin != self.cur_gq_bin_index):
            self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
            self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
        elif (_gt != self.cur_gt):
            self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
            self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
        elif (_chr != self.cur_chr):
            self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
            self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
            [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
        else:
            '''        
            # do not consider DP 
            if(_DP < self.cur_min_DP):
                self.cur_min_DP = _DP
            if(_raw_gq < self.cur_raw_gq):
                self.cur_raw_gq = _raw_gq
            self.current_block.append(cur_item)
            '''

            if (_DP < self.cur_min_DP):
                tmp_cur_min_DP = _DP
                if (self.cur_max_DP > math.ceil((tmp_cur_min_DP + min(3, tmp_cur_min_DP * 0.3)))):
                    self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
                    self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
                    [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
                else:
                    self.cur_min_DP = tmp_cur_min_DP
                    if (_raw_gq < self.cur_raw_gq):
                        self.cur_raw_gq = _raw_gq
                    self.current_block.append(cur_item)
            elif (_DP > self.cur_max_DP):
                if (_DP <= math.ceil(self.cur_min_DP + min(3, self.cur_min_DP * 0.3))):
                    self.cur_max_DP = _DP
                    if (_raw_gq < self.cur_raw_gq):
                        self.cur_raw_gq = _raw_gq
                    self.current_block.append(cur_item)
                else:
                    self.write_to_gvcf_batch(self.current_block, self.cur_min_DP, self.cur_raw_gq)
                    self.current_block, self.cur_gq_bin_index, self.cur_gt, self.cur_min_DP, self.cur_max_DP, self.cur_chr, self.cur_raw_gq = (
                    [cur_item], _gq_bin, _gt, _DP, _DP, _chr, _raw_gq)
            else:
                if (_raw_gq < self.cur_raw_gq):
                    self.cur_raw_gq = _raw_gq
                self.current_block.append(cur_item)

    def reference_likelihood(self, variant_summary):

        '''
        for non-variant sites, this function is calculate the GQ,QUAL,PL,etc for the genotype 0/0 or ./.
        '''

        n_ref = variant_summary["n_ref"]
        n_total = variant_summary['n_total']

        validPL, gq, binned_gq, log10_probs = self._cal_reference_likelihood(n_ref, n_total)
        if (validPL):
            gt = '0/0'
        else:
            gt = './.'
        _tmp_phred_probs = [-10 * x for x in log10_probs]
        min_phred_probs = min(_tmp_phred_probs)

        phred_probs = [int(x - min_phred_probs) for x in _tmp_phred_probs]

        non_variant_info = {"validPL": validPL, "gq": gq, "binned_gq": binned_gq, "pl": phred_probs,
                            "chr": variant_summary['chr'], 'pos': variant_summary['pos'], 'ref': variant_summary['ref'],
                            "gt": gt, 'min_dp': variant_summary['n_total'], 'END': variant_summary['pos']}

        return non_variant_info
        pass

    def _cal_reference_likelihood(self, n_ref, n_total):

        '''
        calculate the phred genotype likelihood for a single non-variant site.
        
        n_ref: number of referece bases
        n_total: number of all bases by ignoring Ns

        P(hom_ref) =  (1-prr)^n_ref*prr^(n_total-n_ref)
        P(Het_alt) = (1/2)^n_total
        P(hom_alt) = prr^n_ref*(1-prr)^(n_total-n_ref)


        return flag of validPL, raw GQ, binned GQ, PLs
        '''

        validPL = True
        if (n_total == 0):
            # when the coverage is 0
            log10_probs = self.constant_log10_probs
            # log10_probs = self.variantMath.normalize_log10_prob([-1.0, -1.0, -1.0])
            pass
        else:

            n_alts = n_total - n_ref
            # logp = math.log(self.p_error) / self.LOG_10
            # log1p = math.log1p(-self.p_error) /self.LOG_10
            log10_p_ref = n_ref * self.log1p + n_alts * self.logp
            # 2 for diploid
            log10_p_het = -n_total * self.LOG_2
            log10_p_hom_alt = n_ref * self.logp + n_alts * self.log1p
            # normalization
            log10_probs = self.variantMath.normalize_log10_prob([log10_p_ref, log10_p_het, log10_p_hom_alt])
        gq = self.variantMath.log10p_to_phred(log10_probs[0])
        gq = int(min(int(gq), self.max_gq))
        if (gq >= 1):
            binned_index = (gq - 1) // self.gq_bin_size
            binned_gq = binned_index * self.gq_bin_size + 1
        else:
            binned_gq = 0

        ''' 
        if(n_total==1):
            logging.info(str(binned_gq)+"\t"+str(gq))
        '''
        validPL = log10_probs[0] == max(log10_probs)
        return validPL, gq, binned_gq, log10_probs

    def _print_vcf_header(self):

        from textwrap import dedent
        print(dedent("""\
            ##fileformat=VCFv4.2
            ##FILTER=<ID=PASS,Description="All filters passed">
            ##FILTER=<ID=LowQual,Description="Confidence in this variant being real is below calling threshold.">
            ##FILTER=<ID=RefCall,Description="Genotyping model thinks this site is reference.">
            ##ALT=<ID=DEL,Description="Deletion">
            ##ALT=<ID=INS,Description="Insertion of novel sequence">
            ##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
            ##INFO=<ID=LENGUESS,Number=.,Type=Integer,Description="Best guess of the indel length">
            ##INFO=<ID=END,Number=1,Type=Integer,Description="End position (for use with symbolic alleles)">
            ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
            ##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
            ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
            ##FORMAT=<ID=MIN_DP,Number=1,Type=Integer,Description="Minimum DP observed within the GVCF block.">
            ##FORMAT=<ID=PL,Number=G,Type=Integer,Description="Phred-scaled genotype likelihoods rounded to the closest integer">
            ##FORMAT=<ID=AF,Number=1,Type=Float,Description="Estimated allele frequency in the range (0,1)">"""), file
              =self.vcf_writer)
        if self.reference_file_path is not None:
            reference_index_file_path = self.reference_file_path + ".fai"
            with open(reference_index_file_path, "r") as fai_fp:
                for row in fai_fp:
                    columns = row.strip().split("\t")
                    contig_name, contig_size = columns[0], columns[1]
                    print("##contig=<ID=%s,length=%s>" % (contig_name, contig_size), file=self.vcf_writer)

        print('#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t%s' % (self.sampleName), file=self.vcf_writer)

        pass

    def _print_ref_info(self):
        pass

    def write_to_gvcf_batch(self, block, block_min_dp, block_min_raw_gq):
        if (self.bp_resolution or block[0]['gt'] == "./."):
            # write it to VCF
            for item in block:
                self.write_to_gvcf(item)

        else:
            start_pos = block[0]['pos']
            end_pos = block[-1]['pos']
            first_PL = block[0]['pl']
            first_gq = block[0]['gq']
            first_binned_gq = block[0]['binned_gq']
            first_gt = block[0]['gt']
            first_ref = block[0]['ref']
            first_chr = block[0]['chr']
            # write binned_gq 
            # non_variant_info = { "gq":first_gq, "binned_gq":first_binned_gq, "pl":first_PL,"chr":first_chr,'pos':start_pos,'ref':first_ref,"gt":first_gt,'min_dp':block_min_dp,'END':end_pos}
            # write min raw gq
            non_variant_info = {"gq": first_gq, "binned_gq": block_min_raw_gq, "pl": first_PL, "chr": first_chr,
                                'pos': start_pos, 'ref': first_ref, "gt": first_gt, 'min_dp': block_min_dp,
                                'END': end_pos}
            self.write_to_gvcf(non_variant_info)

    def write_to_gvcf(self, variant_info):

        '''
        write a temporary file gvcf. This file is needed to be merged with model variant calls.
        '''

        _tmpLine = str(variant_info["chr"]) + '\t' + str(variant_info["pos"]) + "\t.\t" + variant_info[
            'ref'] + '\t<*>\t0\t.\tEND=' + str(variant_info['END']) + '\tGT:GQ:MIN_DP:PL\t' + variant_info[
                       'gt'] + ':' + str(variant_info['binned_gq']) + ':' + str(variant_info['min_dp']) + ':' + str(
            variant_info['pl'][0]) + ',' + str(variant_info['pl'][1]) + ',' + str(variant_info['pl'][2])
        print(_tmpLine, file=self.vcf_writer)

    def make_gvcf(self, variant_counts):

        '''
        the main algorithm is the calculate the non-variant information for the whole genome,
        and output a iterable object.
        when combine it with variantCalls with the calledVariant, we might break the block if the called variant is within a non-variant block.
        variant_counts: iterable object. item:a dictionary {chr,pos,ref_base,n_total,n_ref},note that when the reference genome is N, ref_base should
        be the bases with maximum allele frequency.
        when refering to total_count, ref_count, only ['A','T','C',"G",'a','t','c','g'] are included.
        make_gvcfs
        return all information for make a gvcf,merged block, bp_resolution
        '''
        # bp resolution  or blocks options here

        variant_info = (self.reference_likelihood(sc) for sc in variant_counts)

        if (self.bp_resolution):
            # write it to VCF
            for item in variant_info:
                yield item
            pass
        else:
            for block, block_min_dp in groupVariant(variant_info):
                '''
                print('#'*20)
                print("block",block)
                print('#'*20)
                '''
                if (block[0]['gt'] == '0/0'):
                    start_pos = block[0]['pos']
                    end_pos = block[-1]['pos']
                    first_PL = block[0]['pl']
                    first_gq = block[0]['gq']
                    first_binned_gq = block[0]['binned_gq']
                    first_gt = block[0]['gt']
                    first_ref = block[0]['ref']
                    first_chr = block[0]['chr']
                    non_variant_info = {"gq": first_gq, "binned_gq": first_binned_gq, "pl": first_PL, "chr": first_chr,
                                        'pos': start_pos, 'ref': first_ref, "gt": first_gt, 'min_dp': block_min_dp,
                                        'END': end_pos}
                    yield non_variant_info

                else:

                    # we will output every single site for uncertain genotype './.' 
                    for single_site_info in block:
                        yield single_site_info


def _test_read_pileup(pileup_file_path):
    '''
    an internal test starts from pileup data, 
    will not be used in the formal version

    '''
    mySummaryCounter = parseString()
    with open(pileup_file_path, 'r') as reader:
        for line in reader:
            line = line.strip('\n').split('\t')
            cur_chr = line[0]
            cur_pos = int(line[1])
            cur_baseString = line[4]
            cur_ref = line[2]
            n_total, n_ref = mySummaryCounter.getAlleleSummary(cur_ref, cur_baseString)
            cur_variant_counts = {'chr': cur_chr, 'pos': cur_pos, 'ref': cur_ref, 'n_total': n_total, 'n_ref': n_ref}
            yield cur_variant_counts
    pass


def _test_make_gvcf(pileup_path):
    myCalculator = variantInfoCalculator('./')

    # toy data
    myCalculator._print_vcf_header()

    variantCounts = [{'chr': 1, 'pos': 1, 'ref': 'A', 'n_total': 10, 'n_ref': 8}]
    for chr_site_info in myCalculator.make_gvcf(_test_read_pileup(pileup_path)):
        myCalculator.write_to_gvcf(chr_site_info)
    pass


def _test_make_gvcf_online(pileup_path, ref_path):
    myCalculator = variantInfoCalculator('./', ref_path)

    pileup_res = _test_read_pileup_to_list(pileup_path)
    for single_variant_info in pileup_res:
        myCalculator.make_gvcf_online(single_variant_info)
    if (len(myCalculator.current_block) != 0):
        myCalculator.write_to_gvcf_batch(myCalculator.current_block, myCalculator.cur_min_DP)


if __name__ == '__main__':
    pass
