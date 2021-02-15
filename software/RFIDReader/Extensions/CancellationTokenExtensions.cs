﻿using System;
using System.Threading;
using System.Threading.Tasks;

namespace RFIDReader.Extensions
{
    static class CancellationTokenExtensions
    {
        public static Task AsTask(this CancellationToken token)
        {
            return new Task(() => throw new InvalidOperationException(), token);
        }

        public static Task<TResult> AsTask<TResult>(this CancellationToken token)
        {
            return new Task<TResult>(() => throw new InvalidOperationException(), token);
        }
    }
}
