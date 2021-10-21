<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="關聯表名稱">
              <a-input placeholder="請輸入關聯表名稱" v-model="queryParam.relateTable"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="關鍵字查詢">
              <a-input placeholder="請輸入關鍵字" v-model="queryParam.keyword"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展開' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>
      <a-button type="primary" icon="download" @click="handleExportXls('多語言')">導出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">導入</a-button>
      </a-upload>
      <a-button type="primary" icon="sync" @click="refleshCache()">刷新緩存</a-button>
      <!-- 高級查詢區域 -->
      <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table區域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">編輯</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">詳情</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="確定刪除嗎?" @confirm="() => handleDelete(record.id)">
                  <a>刪除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <sys-translate-modal ref="modalForm" @ok="modalFormOk"></sys-translate-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import SysTranslateModal from './modules/SysTranslateModal'
  import { getAction } from '@/api/manage'
  import { UI_CACHE_TRANSLATE_DATA } from '@/store/mutation-types'

  export default {
    name: 'SysTranslateList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      SysTranslateModal
    },
    data () {
      return {
        description: '多語言管理頁面',
        // 表頭
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'關聯表名稱',
            align:"center",
            dataIndex: 'relateTable'
          },
          {
            title:'關聯主鍵id',
            align:"center",
            dataIndex: 'relateId'
          },
          {
            title:'原文',
            align:"center",
            dataIndex: 'text'
          },
          {
            title:'中文',
            align:"center",
            dataIndex: 'chinese'
          },
          {
            title:'繁體中文',
            align:"center",
            dataIndex: 'taiwan'
          },
          {
            title:'英語',
            align:"center",
            dataIndex: 'english'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "sys/sysTranslate/alllist",
          delete: "sys/sysTranslate/delete",
          deleteBatch: "/sys/sysTranslate/deleteBatch",
          exportXlsUrl: "/sys/sysTranslate/exportXls",
          importExcelUrl: "sys/sysTranslate/importExcel",
          refleshCache: "sys/sysTranslate/refleshCache",
          queryAllDictItems: "sys/sysTranslate/queryAllDictItems",
        },
        dictOptions:{},
        superFieldList:[],
      }
    },
    created() {
    this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'relateTable',text:'關聯表名稱',dictCode:''})
        fieldList.push({type:'string',value:'relateId',text:'關聯主鍵id',dictCode:''})
        fieldList.push({type:'string',value:'chinese',text:'中文',dictCode:''})
        fieldList.push({type:'string',value:'taiwan',text:'繁體中文',dictCode:''})
        fieldList.push({type:'string',value:'english',text:'英語',dictCode:''})
        this.superFieldList = fieldList
      },
      refleshCache(){
        getAction(this.url.refleshCache).then((res) => {
          if (res.success) {
            //重新加載緩存
            getAction(this.url.queryAllDictItems).then((res) => {
              if (res.success) {
                Vue.ls.remove(UI_CACHE_TRANSLATE_DATA)
                Vue.ls.set(UI_CACHE_TRANSLATE_DATA, res.result, 7 * 24 * 60 * 60 * 1000)
              }
            })
            this.$message.success("刷新緩存完成！");
          }
        }).catch(e=>{
          this.$message.warn("刷新緩存失敗！");
          console.log("刷新失敗",e)
        })
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>