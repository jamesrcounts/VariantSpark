package au.csiro.variantspark.pedigree

import scala.collection.mutable.HashMap
import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.Buffer

// I need some recombination pattern of the specific recombination chosen for 
// for each homozigote (from one parent each)
// So essentially for each chromosome I need to model how many and where the recombination happened

/**
 * Represents a diplod indexed genotype
 * TODO: Rename to include diploid
 */
case class GenotypeSpec(val p:Int) extends AnyVal {
  def _0: Int = p & ((p << 16) -1)
  def _1: Int = (p >> 16)
  def apply(index:Int): Int = if (index == 0) _0 else if (index == 1) _1 else throw new IllegalArgumentException()
}

object GenotypeSpec {
  def apply(p0:Int, p1: Int) = {
    assert(p0 >=0 && p0 < (1<<16) && p1 >=0 && p1 < (1<<16),s"p0=${p0}, p1=${p1}")
    new GenotypeSpec(p0 & (p1 << 16))
  }   
}

case class GenomicPos(val contig:ContigID, pos:Long)

trait MutableVariant {
  def contig: ContigID
  def pos: Long
  def ref: BasesVariant
  def getOrElseUpdate(alt: BasesVariant):IndexedVariant
}

/**
 * List of cross-over points for a single contig (chromosome)
 * The list needs to be sorted (or will be sorted as needed)
 * for pos <  crossingOvers(0) -> chromosome 0
 * for crossingOvers(0) <= pos < crossingOvers(1) -> chromosome 1
 * for crossingOvers(1) <= pos < crossingOvers(2) -> chromosome 0 
 * etc ...
 * @param startWith: which chromosome in the pair to start with ( 0 or 1)
 */
case class MeiosisSpec(crossingOvers:List[Long], startWith:Int = 0) {
  
  def getChromosomeAt(pos:Long):Int  = {
    // the meiosis spec array should be sorted so essentially 
    // we just need to find out how may crossing points is before  this pos
    // 
    val noOfCrossOvers = crossingOvers.zipWithIndex.find(_._1 >  pos)
          .map(_._2).getOrElse(crossingOvers.length)
    // now an even number means first chromosome and an odd number the second
    (noOfCrossOvers + startWith)  % 2
  }
}

/**
 * Full specification a homozigote recombination patterns.
 * This can be now used to create the parental homozigore from the actual chromosome information
 */
case class GameteSpec(val splits:Map[ContigID, MeiosisSpec], val mutations:MutationSet =  MutationSet.Empty)  {
  assert(splits.isInstanceOf[Serializable])
  
  def homozigoteAt(v: MutableVariant, genotype: GenotypeSpec):Int = {
    // depending on the recombination pattersn return the allele from either the first 
    // or the second chromosome
    
    // check first for mutations
    // TODO: it appears that even thought the vcf is muliallelic
    // there are still possibilites for repeated positions with different references
    // e.g. one for SNPs and one for deletions
    mutations.get(GenomicPos(v.contig,v.pos)).flatMap(m =>
      if (m.ref == v.ref) Some(v.getOrElseUpdate(m.alt)) else None
    ).getOrElse(genotype(splits(v.contig).getChromosomeAt(v.pos)))   
  }
}

trait MeiosisSpecFactory {
  def createMeiosisSpec(): Map[ContigID, MeiosisSpec]
}

case class GameteSpecFactory(msf: MeiosisSpecFactory, mf: Option[MutationSetFactory] = None)  {
  //TODO: Add gender distintion
  def createGameteSpec():GameteSpec = GameteSpec(msf.createMeiosisSpec(),
        mf.map(_.create()).getOrElse(MutationSet.Empty))
}

case class OffspringSpec(val fatherGamete: GameteSpec, val motherGamete: GameteSpec) {
  
  def genotypeAt(v:MutableVariant, fatherGenotype:GenotypeSpec, motherGenotype:GenotypeSpec):GenotypeSpec = {
    GenotypeSpec(motherGamete.homozigoteAt(v, motherGenotype), 
        fatherGamete.homozigoteAt(v, fatherGenotype))
  }
}

object OffspringSpec {  
  def create(gsf: GameteSpecFactory)  = OffspringSpec(
      motherGamete = gsf.createGameteSpec(), 
      fatherGamete = gsf.createGameteSpec()
  )
}




