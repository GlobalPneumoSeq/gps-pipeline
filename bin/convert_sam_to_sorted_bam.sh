# Convet SAM to sorted BAM file
# Remove source SAM file if $LITE is true

# Thread usage is capped as memory usage is per thread, and the speed gain level-off as thread count increases 
AVAILABLE_THREAD=$(nproc)
THREAD=$(( AVAILABLE_THREAD > MAX_THREAD ? MAX_THREAD : AVAILABLE_THREAD ))

samtools sort -@ "$THREAD" -o "$SORTED_BAM" "$SAM"

if [ "$LITE" = true ]; then
    rm "$(readlink -f "$SAM")"
fi
