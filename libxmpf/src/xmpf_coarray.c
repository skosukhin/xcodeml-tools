#include "xmpf_internal.h"

typedef struct {
  BOOL    is_used;
  void   *desc;
  void   *orgAddr;
  int     count;
  size_t  element;
} _coarrayInfo_t;

static _coarrayInfo_t _coarrayInfoTab[DESCR_ID_MAX] = {};
static int _nextId = 0;

static int _getNewSerno();
static int _set_coarrayInfo(void *desc, void *orgAddr, int count, size_t element);


/*****************************************\
  internal information management
\*****************************************/

int xmpf_get_coarrayElement(int serno)
{
  return _coarrayInfoTab[serno].element;
}

void* xmpf_get_coarrayDesc(int serno)
{
  return _coarrayInfoTab[serno].desc;
}

int xmpf_get_coarrayStart(int serno, void* baseAddr)
{
  int element = _coarrayInfoTab[serno].element;
  void* orgAddr = _coarrayInfoTab[serno].orgAddr;
  int start = ((size_t)baseAddr - (size_t)orgAddr) / element;
  return start;
}


int _set_coarrayInfo(void *desc, void *orgAddr, int count, size_t element)
{
  int serno;

  serno = _getNewSerno();
  if (serno < 0) {         /* fail */
    _XMP_fatal("xmpf_coarray.c: no more desc table.");
    return serno;
  }

  _coarrayInfoTab[serno].is_used = TRUE;
  _coarrayInfoTab[serno].desc = desc;
  _coarrayInfoTab[serno].orgAddr = orgAddr;
  _coarrayInfoTab[serno].count = count;
  _coarrayInfoTab[serno].element = element;

  return serno;
}

static int _getNewSerno() {
  int i;

  /* try white area */
  for (i = _nextId; i < DESCR_ID_MAX; i++) {
    if (! _coarrayInfoTab[i].is_used) {
      ++_nextId;
      return i;
    }
  }

  /* try reuse */
  for (i = 0; i < _nextId; i++) {
    if (! _coarrayInfoTab[i].is_used) {
      _nextId = i + 1;
      return i;
    }
  }

  /* error: no room */
  return -1;
}


/*****************************************\
  MALLOC
\*****************************************/

void xmpf_coarray_malloc_(int *serno, void **pointer, int *count, int *element)
{
  xmpf_coarray_malloc(serno, pointer, *count, (size_t)(*element));
}

void xmpf_coarray_malloc(int *serno, void **pointer, int count, size_t element)
{
  void* desc;
  void* orgAddr;

  // see libxmp/src/xmp_coarray_set.c
  _XMP_coarray_malloc_info_1(count, element);  
  _XMP_coarray_malloc_image_info_1();
  _XMP_coarray_malloc_do(&desc, &orgAddr);

  *pointer = orgAddr;
  *serno = _set_coarrayInfo(desc, orgAddr, count, element);
}


