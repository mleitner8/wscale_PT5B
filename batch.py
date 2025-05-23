from netpyne.batchtools.search import search
import numpy as np
import json

sections = list(json.load(open('Na12HH16HH_TF.json', 'r'))['secs'].keys())
weights = list(np.arange(0.01, 0.2, 0.01)/100.0) 
# Create parameter grid for search
params = {
    'sec'   : sections,
    'weight': weights,
}

# use batch_sge_config if running on a
sge_config = {
    'queue': 'cpu.q',
    'cores': 2,
    'vmem': '4G',
    'realtime': '04:00:00',
    'command': 'python test.py'}


result_grid = search(job_type = 'sge',
       comm_type       = "socket",
       params          = params,
       run_config      = sge_config,
       label           = "grid_search",
       output_path     = "./grid_batch",
       checkpoint_path = "./ray",
       num_samples     = 1,
       metric          = 'epsp',
       mode            = 'min',
       algorithm       = "variant_generator",
       max_concurrent  = 9)
