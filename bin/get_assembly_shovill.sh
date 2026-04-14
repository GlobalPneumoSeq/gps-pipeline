# Run Shovill to get assembly
# Set to use all available threads up to 16 if not specify

if [ "$THREAD" = '0' ]; then 
    THREAD=$(nproc)
    CAP="16"
    [ "$THREAD" -gt "$CAP" ] && THREAD="$CAP"
fi

shovill --R1 "$READ1" --R2 "$READ2" --outdir results --cpus "$THREAD" --minlen "$MIN_CONTIG_LENGTH" --force
mv results/contigs.fa "$FASTA"
